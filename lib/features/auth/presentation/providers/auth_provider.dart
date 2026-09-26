import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/di/providers.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

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
        final current = state.user;
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: (current != null && current.uid == user.uid) ? current : user,
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
    try {
      final result = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      result.fold(_fail, _succeed);
    } catch (e) {
      _failUnexpected(e);
    }
  }

  Future<void> signUpWithEmail(
      String email, String password, String name) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final result = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      result.fold(_fail, _succeed);
    } catch (e) {
      _failUnexpected(e);
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final result = await _authRepository.signInWithGoogle();
      result.fold(_fail, _succeed);
    } catch (e) {
      _failUnexpected(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final result = await _authRepository.sendPasswordResetEmail(email);
      result.fold(
        _fail,
        (_) {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            clearError: true,
          );
        },
      );
    } catch (e) {
      _failUnexpected(e);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final result = await _authRepository.sendEmailVerification();
      result.fold(
        _fail,
        (_) {},
      );
    } catch (e) {
      _failUnexpected(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      _failUnexpected(e);
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _authRepository.deleteAccount();
      result.fold(
        _fail,
        (_) {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            clearUser: true,
          );
        },
      );
    } catch (e) {
      _failUnexpected(e);
    }
  }

  Future<bool> isPrivacyPolicyAccepted() async {
    return _authRepository.isPrivacyPolicyAccepted();
  }

  /// Persists the privacy-policy acceptance remotely. Returns true only when
  /// the acceptance was actually recorded (so a failure such as an offline
  /// connection does not bounce the user into the app while the backend still
  /// expects acceptance on the next launch).
  Future<bool> acceptPrivacyPolicy(String version) async {
    try {
      final result = await _authRepository.acceptPrivacyPolicy(version);
      var accepted = false;
      result.fold(
        (failure) {
          state = state.copyWith(errorMessage: failure.message);
        },
        (_) {
          accepted = true;
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
      return accepted;
    } catch (e) {
      _failUnexpected(e);
      return false;
    }
  }

  void _succeed(AppUser user) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      clearError: true,
    );
  }

  void _fail(Failure failure) {
    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: failure.message,
    );
  }

  void _failUnexpected(Object error) {
    debugPrint('Auth error: $error');
    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: 'Something went wrong. Please try again.',
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

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
