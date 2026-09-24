import '../constants/app_constants.dart';

class Validators {
  Validators._();
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < AppConstants.minPasswordLength) {
      return 'Password must be ${AppConstants.minPasswordLength}+ characters';
    }
    return null;
  }
  static String? confirmPassword(String? v, String pw) {
    if (v == null || v.isEmpty) return 'Confirm your password';
    if (v != pw) return 'Passwords do not match';
    return null;
  }
  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    if (v.trim().length < 2) return 'Name must be 2+ characters';
    return null;
  }
}
