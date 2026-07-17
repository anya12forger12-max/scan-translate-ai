import 'package:equatable/equatable.dart';

enum UserRole { user, admin }

class AppUser extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final bool emailVerified;
  final bool privacyPolicyAccepted;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role = UserRole.user,
    this.emailVerified = false,
    this.privacyPolicyAccepted = false,
    required this.createdAt,
    this.lastLoginAt,
  });

  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoUrl,
        role,
        emailVerified,
        privacyPolicyAccepted,
        createdAt,
        lastLoginAt,
      ];
}
