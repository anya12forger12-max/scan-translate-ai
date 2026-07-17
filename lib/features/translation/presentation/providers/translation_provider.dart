import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/translation_result.dart';

enum TranslationStatus { initial, loading, translating, success, error }

class TranslationState {
  final TranslationStatus status;
  final TranslationResult? result;
  final String? errorMessage;
  final String sourceLanguage;
  final String targetLanguage;

  const TranslationState({
    this.status = TranslationStatus.initial,
    this.result,
    this.errorMessage,
    this.sourceLanguage = 'auto',
    this.targetLanguage = 'en',
  });

  TranslationState copyWith({
    TranslationStatus? status,
    TranslationResult? result,
    String? errorMessage,
    String? sourceLanguage,
    String? targetLanguage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return TranslationState(
      status: status ?? this.status,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }
}

class TranslationNotifier extends StateNotifier<TranslationState> {
  TranslationNotifier() : super(const TranslationState());

  void setSourceLanguage(String lang) {
    state = state.copyWith(sourceLanguage: lang);
  }

  void setTargetLanguage(String lang) {
    state = state.copyWith(targetLanguage: lang);
  }

  void swapLanguages() {
    state = state.copyWith(
      sourceLanguage: state.targetLanguage,
      targetLanguage: state.sourceLanguage,
    );
  }

  void setResult(TranslationResult result) {
    state = state.copyWith(status: TranslationStatus.success, result: result);
  }

  void setLoading() {
    state = state.copyWith(
      status: TranslationStatus.loading,
      clearError: true,
      clearResult: true,
    );
  }

  void setTranslating() {
    state = state.copyWith(status: TranslationStatus.translating);
  }

  void setError(String message) {
    state = state.copyWith(status: TranslationStatus.error, errorMessage: message);
  }

  void reset() {
    state = const TranslationState();
  }
}

final translationProvider =
    StateNotifierProvider<TranslationNotifier, TranslationState>((ref) {
  return TranslationNotifier();
});
