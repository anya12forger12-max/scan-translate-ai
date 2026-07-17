import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivacyPolicyState {
  final bool isAccepted;
  final String? acceptedVersion;
  final String currentVersion;
  final bool mustAccept;

  const PrivacyPolicyState({
    this.isAccepted = false,
    this.acceptedVersion,
    this.currentVersion = '1.0',
    this.mustAccept = false,
  });

  PrivacyPolicyState copyWith({
    bool? isAccepted,
    String? acceptedVersion,
    String? currentVersion,
    bool? mustAccept,
  }) {
    return PrivacyPolicyState(
      isAccepted: isAccepted ?? this.isAccepted,
      acceptedVersion: acceptedVersion ?? this.acceptedVersion,
      currentVersion: currentVersion ?? this.currentVersion,
      mustAccept: mustAccept ?? this.mustAccept,
    );
  }
}

class PrivacyPolicyNotifier extends StateNotifier<PrivacyPolicyState> {
  PrivacyPolicyNotifier() : super(const PrivacyPolicyState());

  void setMustAccept(bool value) {
    state = state.copyWith(mustAccept: value);
  }

  void accept(String version) {
    state = state.copyWith(
      isAccepted: true,
      acceptedVersion: version,
      mustAccept: false,
    );
  }

  void reset() {
    state = const PrivacyPolicyState();
  }
}

final privacyPolicyProvider =
    StateNotifierProvider<PrivacyPolicyNotifier, PrivacyPolicyState>((ref) {
  return PrivacyPolicyNotifier();
});
