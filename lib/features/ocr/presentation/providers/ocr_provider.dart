import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ocr_result.dart';

enum OcrStatus { initial, loading, success, error }

class OcrState {
  final OcrStatus status;
  final OcrResult? result;
  final String? errorMessage;
  const OcrState({this.status = OcrStatus.initial, this.result, this.errorMessage});
  OcrState copyWith({OcrStatus? status, OcrResult? result, String? errorMessage, bool clrR = false, bool clrE = false}) =>
    OcrState(status: status ?? this.status, result: clrR ? null : (result ?? this.result), errorMessage: clrE ? null : (errorMessage ?? this.errorMessage));
}

class OcrNotifier extends StateNotifier<OcrState> {
  OcrNotifier() : super(const OcrState());
  void setLoading() => state = state.copyWith(status: OcrStatus.loading, clrE: true, clrR: true);
  void setResult(OcrResult r) => state = state.copyWith(status: OcrStatus.success, result: r);
  void setError(String m) => state = state.copyWith(status: OcrStatus.error, errorMessage: m);
  void reset() => state = const OcrState();
}

final ocrProvider = StateNotifierProvider<OcrNotifier, OcrState>((ref) => OcrNotifier());
