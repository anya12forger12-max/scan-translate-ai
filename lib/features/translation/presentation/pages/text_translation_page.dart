import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_display.dart';
import '../providers/translation_provider.dart';
import '../widgets/language_selector.dart';
import '../widgets/translation_card.dart';
import '../../data/repositories/translation_repository_impl.dart';

class TextTranslationPage extends ConsumerStatefulWidget {
  final String? initialText;

  const TextTranslationPage({super.key, this.initialText});

  @override
  ConsumerState<TextTranslationPage> createState() =>
      _TextTranslationPageState();
}

class _TextTranslationPageState extends ConsumerState<TextTranslationPage> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _textController.text = widget.initialText!;
      _translate();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _translate() {
    if (_textController.text.trim().isEmpty) return;
    HapticUtils.mediumImpact();
    final state = ref.read(translationProvider);
    final repo = ref.read(translationRepositoryProvider);

    ref.read(translationProvider.notifier).setLoading();
    repo
        .translateText(
          text: _textController.text.trim(),
          targetLanguage: state.targetLanguage,
          sourceLanguage: state.sourceLanguage == 'auto' ? null : state.sourceLanguage,
        )
        .then((result) {
      result.fold(
        (failure) =>
            ref.read(translationProvider.notifier).setError(failure.message),
        (result) =>
            ref.read(translationProvider.notifier).setResult(result),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final transState = ref.watch(translationProvider);
    final transNotifier = ref.read(translationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Translation'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Language Selectors
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
            const SizedBox(height: 16),
            // Input Text Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Semantics(
                label: 'Text to translate',
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: 5,
                  minLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter text to translate...',
                    alignLabelWithHint: true,
                    suffixIcon: _textController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _textController.clear();
                              transNotifier.reset();
                            },
                          )
                        : null,
                  ),
                  textInputAction: TextInputAction.newline,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: transState.status == TranslationStatus.loading
                    ? null
                    : _translate,
                icon: const Icon(Icons.translate_rounded),
                label: Text(
                  transState.status == TranslationStatus.loading
                      ? 'Translating...'
                      : 'Translate',
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
                onAction: _translate,
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
                  Share.share(transState.result!.translatedText);
                },
              ),
          ],
        ),
      ),
    );
  }
}
