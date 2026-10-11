// ignore_for_file: must_be_immutable
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';

import 'package:scan_translate_ai/core/errors/exceptions.dart';
import 'package:scan_translate_ai/features/auth/data/datasources/auth_remote_datasource.dart';

/// A hand-written fake rather than a pure mockito stub.
///
/// `Mock.noSuchMethod` returns `null`, and [FirebaseAuth]'s sign-in/up methods
/// are declared with non-nullable `Future<UserCredential>` returns, so a
/// `when(...)` on them throws a null-not-a-subtype runtime error before the
/// stub can ever be installed. Overriding
/// the two methods as real `async` functions produces an actual failed
/// `Future` for the datasource to catch.
class MockFirebaseAuth extends Mock implements fb.FirebaseAuth {
  fb.FirebaseAuthException? signInError;
  fb.FirebaseAuthException? createError;

  @override
  Future<fb.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (signInError != null) throw signInError!;
    throw UnimplementedError('signInWithEmailAndPassword was not configured');
  }

  @override
  Future<fb.UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (createError != null) throw createError!;
    throw UnimplementedError('createUserWithEmailAndPassword was not configured');
  }
}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

fb.FirebaseAuthException _authError(String code) =>
    fb.FirebaseAuthException(code: code, message: 'raw sdk message');

void main() {
  late MockFirebaseAuth auth;
  late AuthRemoteDataSource datasource;

  setUp(() {
    auth = MockFirebaseAuth();
    datasource = AuthRemoteDataSource(
      firebaseAuth: auth,
      firestore: MockFirebaseFirestore(),
      googleSignIn: MockGoogleSignIn(),
    );
  });

  group('sign-in keeps account codes masked', () {
    test('email-already-in-use on sign-in is masked', () async {
      auth.signInError = _authError('email-already-in-use');

      await expectLater(
        datasource.signInWithEmail(email: 'a@b.c', password: 'x'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Invalid email or password.',
        )),
      );
    });

    test('wrong-password stays masked', () async {
      auth.signInError = _authError('wrong-password');

      await expectLater(
        datasource.signInWithEmail(email: 'a@b.c', password: 'x'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Invalid email or password.',
        )),
      );
    });
  });

  group('registration discloses the real reason', () {
    test('email-already-in-use on sign-up tells the user to sign in', () async {
      auth.createError = _authError('email-already-in-use');

      await expectLater(
        datasource.signUpWithEmail(email: 'a@b.c', password: 'x', name: 'A'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'An account with this email already exists. Please sign in instead.',
        )),
      );
    });

    test('sign-up message is not the masked sign-in one', () async {
      auth.createError = _authError('email-already-in-use');

      try {
        await datasource.signUpWithEmail(
            email: 'a@b.c', password: 'x', name: 'A');
        fail('expected an AuthException');
      } on AuthException catch (e) {
        expect(e.message, isNot('Invalid email or password.'));
      }
    });
  });

  group('account-exists is always disclosed', () {
    test(
        'account-exists-with-different-credential is not masked even on the sign-in path',
        () async {
      auth.signInError = _authError('account-exists-with-different-credential');

      await expectLater(
        datasource.signInWithEmail(email: 'a@b.c', password: 'x'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'This email is already registered with a different sign-in method.',
        )),
      );
    });
  });
}
