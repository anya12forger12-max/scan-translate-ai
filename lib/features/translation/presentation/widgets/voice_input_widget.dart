import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class VoiceInputWidget extends StatefulWidget {
  final bool isListening;
  final VoidCallback onStartListening;
  final VoidCallback onStopListening;
  final String recognizedText;

  const VoiceInputWidget({
    super.key,
    required this.isListening,
    required this.onStartListening,
    required this.onStopListening,
    this.recognizedText = '',
  });

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(VoiceInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: widget.isListening
              ? 'Listening for speech. Tap to stop.'
              : 'Tap to start voice input',
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isListening ? _pulseAnimation.value : 1.0,
                child: GestureDetector(
                  onTap: widget.isListening
                      ? widget.onStopListening
                      : widget.onStartListening,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isListening
                          ? AppColors.error.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.1),
                      border: Border.all(
                        color: widget.isListening
                            ? AppColors.error
                            : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      widget.isListening
                          ? Icons.mic_rounded
                          : Icons.mic_none_rounded,
                      size: 36,
                      color: widget.isListening
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.isListening ? 'Listening...' : 'Tap to speak',
          style: AppTypography.bodyMedium.copyWith(
            color: widget.isListening ? AppColors.error : AppColors.textSecondary,
          ),
        ),
        if (widget.recognizedText.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.recognizedText,
              style: AppTypography.bodyLarge,
            ),
          ),
        ],
      ],
    );
  }
}
