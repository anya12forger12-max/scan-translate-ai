import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;
  const AuthState({this.status = AuthStatus.initial, this.user, this.errorMessage});
  AuthState copyWith({AuthStatus? status, AppUser? user, String? errorMessage, bool clrU = false, bool clrE = false}) =>
    AuthState(status: status ?? this.status, user: clrU ? null : (user ?? this.user), errorMessage: clrE ? null : (errorMessage ?? this.errorMessage));
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  AuthNotifier(this._repo) : super(const AuthState()) {
    _repo.authStateChanges.listen((u) {
      state = state.copyWith(status: u != null ? AuthStatus.authenticated : AuthStatus.unauthenticated, user: u, clrE: true);
    });
  }

  Future<void> signInWithEmail(String email, String pw) async {
    state = state.copyWith(status: AuthStatus.loading, clrE: true);
    (await _repo.signInWithEmail(email: email, password: pw)).fold(
      (f) => state = state.copyWith(status: AuthStatus.error, errorMessage: f.message),
      (u) => state = state.copyWith(status: AuthStatus.authenticated, user: u, clrE: true),
    );
  }

  Future<void> signUpWithEmail(String email, String pw, String name) async {
    state = state.copyWith(status: AuthStatus.loading, clrE: true);
    (await _repo.signUpWithEmail(email: email, password: pw, name: name)).fold(
      (f) => state = state.copyWith(status: AuthStatus.error, errorMessage: f.message),
      (u) => state = state.copyWith(status: AuthStatus.authenticated, user: u, clrE: true),
    );
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, clrE: true);
    (await _repo.signInWithGoogle()).fold(
      (f) => state = state.copyWith(status: AuthStatus.error, errorMessage: f.message),
      (u) => state = state.copyWith(status: AuthStatus.authenticated, user: u, clrE: true),
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(status: AuthStatus.loading, clrE: true);
    (await _repo.sendPasswordResetEmail(email)).fold(
      (f) => state = state.copyWith(status: AuthStatus.error, errorMessage: f.message),
      (_) => state = state.copyWith(status: AuthStatus.initial),
    );
  }

  Future<void> sendEmailVerification() async {
    (await _repo.sendEmailVerification()).fold(
      (f) => state = state.copyWith(errorMessage: f.message), (_) {});
  }

  Future<void> signOut() async { await _repo.signOut(); }
  Future<void> deleteAccount() async { await _repo.deleteAccount(); }
  Future<bool> isPrivacyPolicyAccepted() async => _repo.isPrivacyPolicyAccepted();

  Future<void> acceptPrivacyPolicy(String version) async {
    (await _repo.acceptPrivacyPolicy(version)).fold((f) => state = state.copyWith(errorMessage: f.message), (_) {});
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => throw UnimplementedError());
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref.watch(authRepositoryProvider)));
final currentUserProvider = Provider<AppUser?>((ref) => ref.watch(authProvider).user);
