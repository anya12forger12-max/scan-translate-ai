import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;

  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, AppUser>> signInWithGoogle();

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  Future<Either<Failure, void>> sendEmailVerification();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> deleteAccount();

  Future<Either<Failure, void>> acceptPrivacyPolicy(String version);

  Future<bool> isPrivacyPolicyAccepted();
}
