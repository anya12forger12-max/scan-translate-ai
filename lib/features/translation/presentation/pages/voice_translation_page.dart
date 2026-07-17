import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/permission_utils.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_display.dart';
import '../providers/translation_provider.dart';
import '../widgets/language_selector.dart';
import '../widgets/voice_input_widget.dart';
import '../widgets/translation_card.dart';

class VoiceTranslationPage extends ConsumerStatefulWidget {
  const VoiceTranslationPage({super.key});

  @override
  ConsumerState<VoiceTranslationPage> createState() =>
      _VoiceTranslationPageState();
}

class _VoiceTranslationPageState extends ConsumerState<VoiceTranslationPage> {
  bool _isListening = false;
  String _recognizedText = '';

  Future<void> _startListening() async {
    final hasPermission = await PermissionUtils.requestMicrophonePermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission required')),
        );
      }
      return;
    }

    HapticUtils.mediumImpact();
    setState(() => _isListening = true);

    final repo = ref.read(translationRepositoryProvider);
    final result = await repo.speechToText(
      language: ref.read(translationProvider).sourceLanguage == 'auto'
          ? null
          : ref.read(translationProvider).sourceLanguage,
    );

    result.fold(
      (failure) {
        if (mounted) {
          setState(() => _isListening = false);
          ref.read(translationProvider.notifier).setError(failure.message);
        }
      },
      (text) {
        if (mounted) {
          setState(() {
            _isListening = false;
            _recognizedText = text;
          });
          _translateText(text);
        }
      },
    );
  }

  void _stopListening() {
    setState(() => _isListening = false);
  }

  void _translateText(String text) {
    if (text.trim().isEmpty) return;

    final transNotifier = ref.read(translationProvider.notifier);
    final transState = ref.read(translationProvider);
    final repo = ref.read(translationRepositoryProvider);

    transNotifier.setLoading();
    repo
        .translateText(
          text: text,
          targetLanguage: transState.targetLanguage,
          sourceLanguage: transState.sourceLanguage == 'auto'
              ? null
              : transState.sourceLanguage,
        )
        .then((result) {
      result.fold(
        (failure) => transNotifier.setError(failure.message),
        (result) => transNotifier.setResult(result),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final transState = ref.watch(translationProvider);
    final transNotifier = ref.read(translationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Translation'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: LanguageSelector(
                      selectedCode: transState.sourceLanguage,
                      onChanged: (lang) => transNotifier.setSourceLanguage(lang),
                      label: 'Source language',
                    ),
                  ),
                  LanguageSwapButton(onTap: () => transNotifier.swapLanguages()),
                  Expanded(
                    child: LanguageSelector(
                      selectedCode: transState.targetLanguage,
                      onChanged: (lang) => transNotifier.setTargetLanguage(lang),
                      label: 'Target language',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            VoiceInputWidget(
              isListening: _isListening,
              onStartListening: _startListening,
              onStopListening: _stopListening,
              recognizedText: _recognizedText,
            ),
            const SizedBox(height: 16),
            if (_recognizedText.isNotEmpty && transState.status != TranslationStatus.loading && transState.status != TranslationStatus.success)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _translateText(_recognizedText),
                    icon: const Icon(Icons.translate_rounded),
                    label: const Text('Translate'),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (transState.status == TranslationStatus.loading)
              const LoadingDisplay(message: 'Translating...'),
            if (transState.status == TranslationStatus.error)
              ErrorDisplay(
                message: transState.errorMessage ?? 'Translation failed.',
                actionLabel: 'Retry',
                onAction: () => transNotifier.reset(),
              ),
            if (transState.status == TranslationStatus.success &&
                transState.result != null)
              TranslationCard(
                result: transState.result!,
                onTextToSpeech: () {
                  final repo = ref.read(translationRepositoryProvider);
                  repo.textToSpeech(
                    text: transState.result!.translatedText,
                    language: transState.targetLanguage,
                  );
                },
                onCopy: () {
                  Clipboard.setData(
                    ClipboardData(text: transState.result!.translatedText),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Translation copied')),
                  );
                },
                onShare: () {
                  SharePlus.instance.share(
                    ShareParams(text: transState.result!.translatedText),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
