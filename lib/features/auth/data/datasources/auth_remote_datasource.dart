import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';

class AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSource({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  Stream<firebase_auth.User?> get authStateChanges => firebaseAuth.authStateChanges();

  firebase_auth.User? get currentUser => firebaseAuth.currentUser;

  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (result.user == null) {
        throw const AuthException('Sign-in failed. Please try again.');
      }
      await _updateLastLogin(result.user!.uid);
      return await _getUserData(result.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (result.user == null) {
        throw const AuthException('Registration failed. Please try again.');
      }
      await result.user!.updateDisplayName(name.trim());
      await result.user!.sendEmailVerification();

      final userModel = {
        'email': email.trim(),
        'displayName': name.trim(),
        'emailVerified': false,
        'privacyPolicyAccepted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      };

      await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(result.user!.uid)
          .set(userModel);

      userModel['uid'] = result.user!.uid;
      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final googleAccount = await googleSignIn.signIn();
      if (googleAccount == null) {
        throw const AuthException('Google sign-in was cancelled.');
      }

      final googleAuth = await googleAccount.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await firebaseAuth.signInWithCredential(credential);
      if (result.user == null) {
        throw const AuthException('Google sign-in failed.');
      }

      final userDoc = await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(result.user!.uid)
          .get();

      if (!userDoc.exists) {
        final userModel = {
          'email': result.user!.email,
          'displayName': result.user!.displayName,
          'photoUrl': result.user!.photoURL,
          'emailVerified': result.user!.emailVerified,
          'privacyPolicyAccepted': false,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        };
        await firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(result.user!.uid)
            .set(userModel);
        userModel['uid'] = result.user!.uid;
        return userModel;
      }

      await _updateLastLogin(result.user!.uid);
      return await _getUserData(result.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw const AuthException('No user logged in.');
      await user.sendEmailVerification();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
      await firebaseAuth.signOut();
    } catch (e) {
      throw const AuthException('Failed to sign out.');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw const AuthException('No user logged in.');

      await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .delete();

      await firestore
          .collection(FirebaseConstants.scanHistoryCollection)
          .where('userId', isEqualTo: user.uid)
          .get()
          .then((snapshot) async {
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      });

      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> acceptPrivacyPolicy(String version) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw const AuthException('No user logged in.');

      await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .update({
        'privacyPolicyAccepted': true,
        'privacyPolicyVersion': version,
        'privacyPolicyAcceptedAt': FieldValue.serverTimestamp(),
      });
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<bool> isPrivacyPolicyAccepted() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return false;

      final doc = await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!doc.exists) return false;
      return doc.data()?['privacyPolicyAccepted'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _getUserData(firebase_auth.User user) async {
    final doc = await firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      data['uid'] = user.uid;
      return data;
    }

    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'emailVerified': user.emailVerified,
      'privacyPolicyAccepted': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _updateLastLogin(String uid) async {
    try {
      await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .update({'lastLoginAt': FieldValue.serverTimestamp()});
    } catch (_) {}
  }

  AuthException _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthException('No account found with this email.');
      case 'wrong-password':
        return const AuthException('Incorrect password. Please try again.');
      case 'invalid-credential':
        return const AuthException('Invalid email or password.');
      case 'invalid-email':
        return const AuthException('Please enter a valid email address.');
      case 'user-disabled':
        return const AuthException('This account has been disabled.');
      case 'email-already-in-use':
        return const AuthException('An account with this email already exists.');
      case 'operation-not-allowed':
        return const AuthException('This sign-in method is not enabled.');
      case 'weak-password':
        return const AuthException('Password is too weak.');
      case 'too-many-requests':
        return const AuthException('Too many attempts. Please try again later.');
      case 'network-request-failed':
        return const AuthException('Network error. Please check your connection.');
      default:
        return AuthException(e.message ?? 'An unexpected error occurred.');
    }
  }
}
