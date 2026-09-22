import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/di/providers.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/permission_utils.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_display.dart';
import '../../../../core/widgets/permission_rationale_dialog.dart';
import '../providers/translation_provider.dart';
import '../widgets/language_selector.dart';
import '../widgets/voice_input_widget.dart';
import '../widgets/translation_card.dart';
import '../../data/datasources/translation_datasource.dart';

class VoiceTranslationPage extends ConsumerStatefulWidget {
  const VoiceTranslationPage({super.key});

  @override
  ConsumerState<VoiceTranslationPage> createState() =>
      _VoiceTranslationPageState();
}

class _VoiceTranslationPageState extends ConsumerState<VoiceTranslationPage> {
  bool _isListening = false;
  String _recognizedText = '';
  late final TranslationRemoteDataSource _speechDatasource;

  @override
  void initState() {
    super.initState();
    // Snapshot the datasource so dispose can cancel an in-flight recognition
    // session without touching the gone element's ref (illegal post-dispose).
    _speechDatasource = ref.read(translationRemoteDataSourceProvider);
    // A fresh visit must never surface an error left over from a previous
    // screen; each page only ever displays state that it produced itself.
    // Riverpod forbids mutating providers during initState/dispose, so the
    // stale state is dropped in the frame that follows the first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(translationProvider.notifier).clearError();
    });
  }

  Future<void> _startListening() async {
    final micGranted = await PermissionUtils.hasMicrophonePermission();
    if (!micGranted && mounted) {
      final proceed = await showPermissionRationale(
        context,
        title: 'Microphone access',
        message:
            'Voice translation uses the microphone to capture your speech '
            'and turn it into text for translation.',
      );
      if (!proceed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission required')),
          );
        }
        return;
      }
    }

    final hasPermission = await PermissionUtils.requestMicrophonePermission();
    if (!hasPermission) {
      if (mounted) {
        final micStatus = await PermissionUtils.microphoneStatus();
        final permanentlyDenied = micStatus == PermissionStatus.permanentlyDenied;
        if (!mounted) return;
        if (permanentlyDenied) {
          await _offerOpenSettings();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission required')),
          );
        }
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
    final datasource = ref.read(translationRemoteDataSourceProvider);
    unawaited(datasource.cancelCurrentSpeechRecognition());
  }

  /// When the microphone permission is permanently denied the system prompt
  /// can no longer be shown, so the only recovery path is the app settings.
  Future<void> _offerOpenSettings() async {
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone permission is off'),
        content: const Text(
            'Voice translation needs microphone access. You can allow it in '
            'the system settings for this app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    if (openSettings == true) {
      await PermissionUtils.openAppSettings();
    }
  }

  @override
  void dispose() {
    // Release the microphone immediately if the user backs out while
    // listening; otherwise the recognizer would keep recording for up to its
    // full listenFor window in the background.
    unawaited(_speechDatasource.cancelCurrentSpeechRecognition());
    super.dispose();
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
      appBar: AppBar(title: const Text('Voice Translation')),
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
                      onChanged: (lang) =>
                          transNotifier.setSourceLanguage(lang),
                      label: 'Source language',
                    ),
                  ),
                  LanguageSwapButton(
                    onTap: () => transNotifier.swapLanguages(),
                  ),
                  Expanded(
                    child: LanguageSelector(
                      selectedCode: transState.targetLanguage,
                      onChanged: (lang) =>
                          transNotifier.setTargetLanguage(lang),
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
            if (_recognizedText.isNotEmpty &&
                transState.status != TranslationStatus.loading &&
                transState.status != TranslationStatus.success)
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
                  Share.share(transState.result!.translatedText);
                },
              ),
          ],
        ),
      ),
    );
  }
}
