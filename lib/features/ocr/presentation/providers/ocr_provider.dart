import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ocr_result.dart';

enum OcrStatus { initial, loading, success, error }

class OcrState {
  final OcrStatus status;
  final OcrResult? result;
  final String? errorMessage;

  const OcrState({
    this.status = OcrStatus.initial,
    this.result,
    this.errorMessage,
  });

  OcrState copyWith({
    OcrStatus? status,
    OcrResult? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return OcrState(
      status: status ?? this.status,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class OcrNotifier extends StateNotifier<OcrState> {
  OcrNotifier() : super(const OcrState());

  void setLoading() {
    state = state.copyWith(status: OcrStatus.loading, clearError: true, clearResult: true);
  }

  void setResult(OcrResult result) {
    state = state.copyWith(status: OcrStatus.success, result: result);
  }

  void setError(String message) {
    state = state.copyWith(status: OcrStatus.error, errorMessage: message);
  }

  void reset() {
    state = const OcrState();
  }
}

final ocrProvider = StateNotifierProvider<OcrNotifier, OcrState>((ref) {
  return OcrNotifier();
});
