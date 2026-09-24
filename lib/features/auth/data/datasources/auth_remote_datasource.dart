import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';

class AuthRemoteDataSource {
  final fa.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSource({required this.firebaseAuth, required this.firestore, required this.googleSignIn});

  Stream<fa.User?> get authStateChanges => firebaseAuth.authStateChanges();
  fa.User? get currentUser => firebaseAuth.currentUser;

  Future<Map<String, dynamic>> signInWithEmail({required String email, required String password}) async {
    try {
      final r = await firebaseAuth.signInWithEmailAndPassword(email: email.trim(), password: password);
      if (r.user == null) throw const AuthException('Sign-in failed.');
      await _updateLastLogin(r.user!.uid);
      return await _getUserData(r.user!);
    } on fa.FirebaseAuthException catch (e) { throw _handleError(e); }
  }

  Future<Map<String, dynamic>> signUpWithEmail({required String email, required String password, required String name}) async {
    try {
      final r = await firebaseAuth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      if (r.user == null) throw const AuthException('Registration failed.');
      await r.user!.updateDisplayName(name.trim());
      await r.user!.sendEmailVerification();
      await firestore.collection(FirebaseConstants.usersCollection).doc(r.user!.uid).set({
        'email': email.trim(), 'displayName': name.trim(), 'role': 'user',
        'emailVerified': false, 'privacyPolicyAccepted': false,
        'createdAt': FieldValue.serverTimestamp(), 'lastLoginAt': FieldValue.serverTimestamp(),
      });
      return {'uid': r.user!.uid, 'email': email.trim(), 'displayName': name.trim(), 'role': 'user'};
    } on fa.FirebaseAuthException catch (e) { throw _handleError(e); }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final ga = await googleSignIn.signIn();
      if (ga == null) throw const AuthException('Google sign-in cancelled.');
      final gaAuth = await ga.authentication;
      final cred = fa.GoogleAuthProvider.credential(accessToken: gaAuth.accessToken, idToken: gaAuth.idToken);
      final r = await firebaseAuth.signInWithCredential(cred);
      if (r.user == null) throw const AuthException('Google sign-in failed.');
      final doc = await firestore.collection(FirebaseConstants.usersCollection).doc(r.user!.uid).get();
      if (!doc.exists) {
        await firestore.collection(FirebaseConstants.usersCollection).doc(r.user!.uid).set({
          'email': r.user!.email, 'displayName': r.user!.displayName, 'photoUrl': r.user!.photoURL,
          'role': 'user', 'emailVerified': r.user!.emailVerified, 'privacyPolicyAccepted': false,
          'createdAt': FieldValue.serverTimestamp(), 'lastLoginAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _updateLastLogin(r.user!.uid);
      }
      return await _getUserData(r.user!);
    } on fa.FirebaseAuthException catch (e) { throw _handleError(e); }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try { await firebaseAuth.sendPasswordResetEmail(email: email.trim()); }
    on fa.FirebaseAuthException catch (e) { throw _handleError(e); }
  }

  Future<void> sendEmailVerification() async {
    final u = firebaseAuth.currentUser;
    if (u == null) throw const AuthException('No user.');
    await u.sendEmailVerification();
  }

  Future<void> signOut() async { await googleSignIn.signOut(); await firebaseAuth.signOut(); }

  Future<void> deleteAccount() async {
    final u = firebaseAuth.currentUser;
    if (u == null) throw const AuthException('No user.');
    await firestore.collection(FirebaseConstants.usersCollection).doc(u.uid).delete();
    final snaps = await firestore.collection(FirebaseConstants.scanHistoryCollection).where('userId', isEqualTo: u.uid).get();
    for (final d in snaps.docs) { await d.reference.delete(); }
    await u.delete();
  }

  Future<void> acceptPrivacyPolicy(String version) async {
    final u = firebaseAuth.currentUser;
    if (u == null) throw const AuthException('No user.');
    await firestore.collection(FirebaseConstants.usersCollection).doc(u.uid).update({
      'privacyPolicyAccepted': true, 'privacyPolicyVersion': version,
      'privacyPolicyAcceptedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> isPrivacyPolicyAccepted() async {
    final u = firebaseAuth.currentUser;
    if (u == null) return false;
    final doc = await firestore.collection(FirebaseConstants.usersCollection).doc(u.uid).get();
    return doc.data()?['privacyPolicyAccepted'] as bool? ?? false;
  }

  Future<Map<String, dynamic>> _getUserData(fa.User u) async {
    final doc = await firestore.collection(FirebaseConstants.usersCollection).doc(u.uid).get();
    if (doc.exists) { final d = doc.data()!; d['uid'] = u.uid; return d; }
    return {'uid': u.uid, 'email': u.email, 'displayName': u.displayName, 'role': 'user'};
  }

  Future<void> _updateLastLogin(String uid) async {
    try { await firestore.collection(FirebaseConstants.usersCollection).doc(uid).update({'lastLoginAt': FieldValue.serverTimestamp()}); } catch (_) {}
  }

  AuthException _handleError(fa.FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => const AuthException('No account found.'),
      'wrong-password' || 'invalid-credential' => const AuthException('Invalid email or password.'),
      'invalid-email' => const AuthException('Invalid email address.'),
      'email-already-in-use' => const AuthException('Email already in use.'),
      'weak-password' => const AuthException('Password is too weak.'),
      'too-many-requests' => const AuthException('Too many attempts. Try later.'),
      'network-request-failed' => const AuthException('Network error.'),
      _ => AuthException(e.message ?? 'An error occurred.'),
    };
  }
}
