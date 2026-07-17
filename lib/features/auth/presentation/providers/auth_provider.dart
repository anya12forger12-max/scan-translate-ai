import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_repository_provider.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState()) {
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          clearError: true,
        );
      }
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    final result = await _authRepository.signInWithEmail(
      email: email,
      password: password,
    );
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        );
      },
    );
  }

  Future<void> signUpWithEmail(
      String email, String password, String name) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    final result = await _authRepository.signUpWithEmail(
      email: email,
      password: password,
      name: name,
    );
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        );
      },
    );
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    final result = await _authRepository.signInWithGoogle();
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        );
      },
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    final result = await _authRepository.sendPasswordResetEmail(email);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(status: AuthStatus.initial);
      },
    );
  }

  Future<void> sendEmailVerification() async {
    final result = await _authRepository.sendEmailVerification();
    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {},
    );
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _authRepository.deleteAccount();
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
        );
      },
    );
  }

  Future<bool> isPrivacyPolicyAccepted() async {
    return _authRepository.isPrivacyPolicyAccepted();
  }

  Future<void> acceptPrivacyPolicy(String version) async {
    final result = await _authRepository.acceptPrivacyPolicy(version);
    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        if (state.user != null) {
          state = state.copyWith(
            user: AppUser(
              uid: state.user!.uid,
              email: state.user!.email,
              displayName: state.user!.displayName,
              photoUrl: state.user!.photoUrl,
              role: state.user!.role,
              emailVerified: state.user!.emailVerified,
              privacyPolicyAccepted: true,
              createdAt: state.user!.createdAt,
            ),
          );
        }
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('Auth repository provider must be overridden');
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authProvider).status;
});

final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});

final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAdmin ?? false;
});
