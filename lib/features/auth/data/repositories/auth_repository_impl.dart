import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<AppUser?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((firebaseUser) {
      if (firebaseUser == null) return null;
      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        emailVerified: firebaseUser.emailVerified,
        createdAt: DateTime.now(),
      );
    });
  }

  @override
  AppUser? get currentUser {
    final user = remoteDataSource.currentUser;
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final data = await remoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );
      return Right(_mapToUser(data));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final data = await remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      return Right(_mapToUser(data));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final data = await remoteDataSource.signInWithGoogle();
      return Right(_mapToUser(data));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure<void>, void>> acceptPrivacyPolicy(String version) async {
    try {
      await remoteDataSource.acceptPrivacyPolicy(version);
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<bool> isPrivacyPolicyAccepted() async {
    return remoteDataSource.isPrivacyPolicyAccepted();
  }

  AppUser _mapToUser(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] as String? ?? '',
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      role: data['role'] as String? == 'admin' ? UserRole.admin : UserRole.user,
      emailVerified: data['emailVerified'] as bool? ?? false,
      privacyPolicyAccepted: data['privacyPolicyAccepted'] as bool? ?? false,
      createdAt: DateTime.now(),
    );
  }
}
