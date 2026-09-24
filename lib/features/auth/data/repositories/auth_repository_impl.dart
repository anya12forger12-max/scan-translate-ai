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
  Stream<AppUser?> get authStateChanges =>
    remoteDataSource.authStateChanges.map((u) => u == null ? null : AppUser(uid: u.uid, email: u.email ?? '', createdAt: DateTime.now()));

  @override
  AppUser? get currentUser {
    final u = remoteDataSource.currentUser;
    return u == null ? null : AppUser(uid: u.uid, email: u.email ?? '', createdAt: DateTime.now());
  }

  @override
  Future<Either<Failure, AppUser>> signInWithEmail({required String email, required String password}) async {
    try { final d = await remoteDataSource.signInWithEmail(email: email, password: password); return Right(_map(d)); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }

  @override
  Future<Either<Failure, AppUser>> signUpWithEmail({required String email, required String password, required String name}) async {
    try { final d = await remoteDataSource.signUpWithEmail(email: email, password: password, name: name); return Right(_map(d)); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try { final d = await remoteDataSource.signInWithGoogle(); return Right(_map(d)); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }

  @override Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try { await remoteDataSource.sendPasswordResetEmail(email); return const Right(null); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }
  @override Future<Either<Failure, void>> sendEmailVerification() async {
    try { await remoteDataSource.sendEmailVerification(); return const Right(null); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }
  @override Future<Either<Failure, void>> signOut() async {
    try { await remoteDataSource.signOut(); return const Right(null); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }
  @override Future<Either<Failure, void>> deleteAccount() async {
    try { await remoteDataSource.deleteAccount(); return const Right(null); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }
  @override Future<Either<Failure, void>> acceptPrivacyPolicy(String version) async {
    try { await remoteDataSource.acceptPrivacyPolicy(version); return const Right(null); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }
  @override Future<bool> isPrivacyPolicyAccepted() async => remoteDataSource.isPrivacyPolicyAccepted();

  AppUser _map(Map<String, dynamic> d) => AppUser(
    uid: d['uid'] as String? ?? '', email: d['email'] as String? ?? '',
    displayName: d['displayName'] as String?, photoUrl: d['photoUrl'] as String?,
    role: d['role'] == 'admin' ? UserRole.admin : UserRole.user,
    emailVerified: d['emailVerified'] as bool? ?? false,
    privacyPolicyAccepted: d['privacyPolicyAccepted'] as bool? ?? false,
    createdAt: DateTime.now(),
  );
}
