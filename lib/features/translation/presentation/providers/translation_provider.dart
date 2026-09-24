import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/translation_result.dart';

enum TranslationStatus { initial, loading, success, error }

class TranslationState {
  final TranslationStatus status;
  final TranslationResult? result;
  final String? errorMessage;
  final String sourceLang, targetLang;
  const TranslationState({this.status = TranslationStatus.initial, this.result, this.errorMessage,
    this.sourceLang = 'auto', this.targetLang = 'en'});
  TranslationState copyWith({TranslationStatus? status, TranslationResult? result, String? errorMessage,
    String? sourceLang, String? targetLang}) =>
    TranslationState(status: status ?? this.status, result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      sourceLang: sourceLang ?? this.sourceLang, targetLang: targetLang ?? this.targetLang);
}

class TranslationNotifier extends StateNotifier<TranslationState> {
  TranslationNotifier() : super(const TranslationState());
  void setLoading() => state = state.copyWith(status: TranslationStatus.loading, result: null, errorMessage: null);
  void setResult(TranslationResult r) => state = state.copyWith(status: TranslationStatus.success, result: r);
  void setError(String m) => state = state.copyWith(status: TranslationStatus.error, errorMessage: m);
  void setSourceLang(String l) => state = state.copyWith(sourceLang: l);
  void setTargetLang(String l) => state = state.copyWith(targetLang: l);
  void swapLanguages() => state = state.copyWith(sourceLang: state.targetLang, targetLang: state.sourceLang == 'auto' ? 'en' : state.sourceLang);
  void reset() => state = const TranslationState();
}

final translationProvider = StateNotifierProvider<TranslationNotifier, TranslationState>((ref) => TranslationNotifier());
