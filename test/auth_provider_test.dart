import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scan_translate_ai/core/errors/failures.dart';
import 'package:scan_translate_ai/features/auth/domain/entities/user.dart';
import 'package:scan_translate_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:scan_translate_ai/features/auth/presentation/providers/auth_provider.dart';

class _FakeAuthRepository implements AuthRepository {
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();

  Future<Either<Failure, AppUser>> Function()? onSignInWithEmail;
  Future<Either<Failure, AppUser>> Function()? onSignUpWithEmail;
  Future<Either<Failure, AppUser>> Function()? onSignInWithGoogle;
  Future<Either<Failure, void>> Function()? onSendPasswordReset;
  Future<Either<Failure, void>> Function()? onDeleteAccount;
  Future<Either<Failure, void>> Function()? onAcceptPrivacyPolicy;

  Future<void> addUserEvent(AppUser? user) async {
    _controller.add(user);
    await Future<void>.delayed(Duration.zero);
  }

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;

  @override
  AppUser? get currentUser => null;

  @override
  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final handler = onSignInWithEmail;
    if (handler != null) return handler();
    return const Left(AuthFailure('No handler'));
  }

  @override
  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final handler = onSignUpWithEmail;
    if (handler != null) return handler();
    return const Left(AuthFailure('No handler'));
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    final handler = onSignInWithGoogle;
    if (handler != null) return handler();
    return const Left(AuthFailure('No handler'));
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    final handler = onSendPasswordReset;
    if (handler != null) return handler();
    return const Left(AuthFailure('No handler'));
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    final handler = onDeleteAccount;
    if (handler != null) return handler();
    return const Left(AuthFailure('No handler'));
  }

  @override
  Future<Either<Failure, void>> acceptPrivacyPolicy(String version) async {
    final handler = onAcceptPrivacyPolicy;
    if (handler != null) return handler();
    return const Left(AuthFailure('No handler'));
  }

  @override
  Future<bool> isPrivacyPolicyAccepted() async {
    return false;
  }
}

AppUser _user({
  String uid = 'u1',
  UserRole role = UserRole.user,
  bool privacyPolicyAccepted = false,
  DateTime? createdAt,
}) {
  return AppUser(
    uid: uid,
    email: 'u@example.com',
    displayName: 'U',
    role: role,
    emailVerified: false,
    privacyPolicyAccepted: privacyPolicyAccepted,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}

void main() {
  late _FakeAuthRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = _FakeAuthRepository();
    container = ProviderContainer(overrides: [
      authProvider.overrideWith((ref) => AuthNotifier(repo)),
    ]);
    addTearDown(container.dispose);
  });

  AuthNotifier notifier() => container.read(authProvider.notifier);
  AuthState state() => container.read(authProvider);

  group('AuthNotifier', () {
    test('a folded AuthFailure surfaces as error status with its message',
        () async {
      repo.onSignInWithEmail = () async =>
          const Left(AuthFailure('Incorrect password. Please try again.'));
      await notifier().signInWithEmail('a@b.c', 'wrong');
      expect(state().status, AuthStatus.error);
      expect(state().errorMessage, 'Incorrect password. Please try again.');
      expect(state().user, isNull);
    });

    test('a repository throw during sign-in reports error, never stuck loading',
        () async {
      repo.onSignInWithEmail = () async => throw StateError('boom');
      await notifier().signInWithEmail('a@b.c', 'secret');
      expect(state().status, AuthStatus.error);
      expect(state().errorMessage, 'Something went wrong. Please try again.');
    });

    test('a repository throw during sign-up reports error, never stuck loading',
        () async {
      repo.onSignUpWithEmail = () async => throw StateError('boom');
      await notifier().signUpWithEmail('a@b.c', 'secret', 'Name');
      expect(state().status, AuthStatus.error);
      expect(state().errorMessage, 'Something went wrong. Please try again.');
    });

    test('a repository throw during Google sign-in reports a friendly error',
        () async {
      repo.onSignInWithGoogle = () async => throw StateError('boom');
      await notifier().signInWithGoogle();
      expect(state().status, AuthStatus.error);
      expect(state().errorMessage, 'Something went wrong. Please try again.');
    });

    test('successful sign-in becomes authenticated with the full user', () async {
      final admin = _user(role: UserRole.admin);
      repo.onSignInWithEmail = () async => Right(admin);
      await notifier().signInWithEmail('a@b.c', 'secret');
      expect(state().status, AuthStatus.authenticated);
      expect(state().user?.isAdmin, isTrue);
    });

    test('password reset success lands on unauthenticated, not initial', () async {
      repo.onSendPasswordReset = () async => const Right(null);
      await notifier().sendPasswordResetEmail('a@b.c');
      expect(state().status, AuthStatus.unauthenticated);
      expect(state().errorMessage, isNull);
    });

    test('password reset repository throw is an error, never stuck loading',
        () async {
      repo.onSendPasswordReset = () async => throw StateError('boom');
      await notifier().sendPasswordResetEmail('a@b.c');
      expect(state().status, AuthStatus.error);
      expect(state().errorMessage, 'Something went wrong. Please try again.');
    });

    test('a stream event does not clobber the fuller user after sign-in',
        () async {
      final admin = _user(role: UserRole.admin, privacyPolicyAccepted: true);
      repo.onSignInWithEmail = () async => Right(admin);
      await notifier().signInWithEmail('a@b.c', 'secret');
      expect(state().user?.isAdmin, isTrue);

      await repo.addUserEvent(_user());
      final kept = container.read(authProvider).user;
      expect(kept?.email, 'u@example.com');
      expect(kept?.isAdmin, isTrue);
      expect(kept?.privacyPolicyAccepted, isTrue);
    });

    test('a deleted-account repository throw is an error, never stuck loading',
        () async {
      repo.onDeleteAccount = () async => throw StateError('boom');
      await notifier().deleteAccount();
      expect(state().status, AuthStatus.error);
      expect(state().errorMessage, 'Something went wrong. Please try again.');
    });

    test('acceptPrivacyPolicy yields false and an error on a repository throw',
        () async {
      repo.onAcceptPrivacyPolicy = () async => throw StateError('boom');
      final accepted = await notifier().acceptPrivacyPolicy('1.0');
      expect(accepted, isFalse);
      expect(state().status, AuthStatus.error);
    });
  });
}