import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String role;
  final bool emailVerified;
  final bool privacyPolicyAccepted;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role = 'user',
    this.emailVerified = false,
    this.privacyPolicyAccepted = false,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory UserModel.fromFirebaseUser(
    String uid,
    String email, {
    String? displayName,
    String? photoUrl,
    bool emailVerified = false,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      emailVerified: emailVerified,
      createdAt: DateTime.now(),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      role: data['role'] as String? ?? 'user',
      emailVerified: data['emailVerified'] as bool? ?? false,
      privacyPolicyAccepted: data['privacyPolicyAccepted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'emailVerified': emailVerified,
      'privacyPolicyAccepted': privacyPolicyAccepted,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  AppUser toEntity() {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      role: role == 'admin' ? UserRole.admin : UserRole.user,
      emailVerified: emailVerified,
      privacyPolicyAccepted: privacyPolicyAccepted,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }
}
