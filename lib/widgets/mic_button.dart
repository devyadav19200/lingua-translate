import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../providers/speech_provider.dart';
import '../providers/history_provider.dart';
import '../models/translation_model.dart';
import '../core/app_colors.dart';

class MicButton extends StatefulWidget {
  const MicButton({super.key});

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _toggleListening(BuildContext context) async {
    final speechProvider = context.read<SpeechProvider>();
    final translationProvider = context.read<TranslationProvider>();

    if (speechProvider.isListening) {
      await speechProvider.stopListening();
      _pulseController.stop();
      _pulseController.reset();
      // Trigger translation after speech stops
      if (translationProvider.sourceText.isNotEmpty) {
        await translationProvider.translate();
        // Save to history
        if (translationProvider.translatedText.isNotEmpty) {
          final model = TranslationModel(
            sourceText: translationProvider.sourceText,
            translatedText: translationProvider.translatedText,
            sourceLang: translationProvider.sourceLang.code,
            targetLang: translationProvider.targetLang.code,
            sourceLangName: translationProvider.sourceLang.name,
            targetLangName: translationProvider.targetLang.name,
          );
          context.read<HistoryProvider>().addToHistory(model);
        }
      }
    } else {
      final success = await speechProvider.startListening(
        onResult: (text) {
          translationProvider.setSourceTextFromSpeech(text);
        },
        languageCode: translationProvider.sourceLang.code == 'auto'
            ? 'en'
            : translationProvider.sourceLang.code,
      );

      if (success) {
        _pulseController.repeat(reverse: true);
      } else {
        _showPermissionDialog(context);
      }
    }
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Microphone Permission'),
        content: const Text(
          'Microphone access is required for voice input.\n\n'
          'Please enable microphone permission in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeechProvider>(
      builder: (context, speechProvider, _) {
        final isListening = speechProvider.isListening;
        final soundLevel =
            (speechProvider.soundLevel.clamp(-2.0, 10.0) + 2) / 12;

        // Sync pulse animation
        if (isListening && !_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        } else if (!isListening && _pulseController.isAnimating) {
          _pulseController.stop();
          _pulseController.reset();
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main Mic Button
                GestureDetector(
                  onTapDown: (_) => _scaleController.forward(),
                  onTapUp: (_) {
                    _scaleController.reverse();
                    _toggleListening(context);
                  },
                  onTapCancel: () => _scaleController.reverse(),
                  child: AnimatedBuilder(
                    animation:
                        Listenable.merge([_pulseAnim, _scaleAnim]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnim.value,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer pulse ring
                            if (isListening)
                              Container(
                                width: 72 * _pulseAnim.value,
                                height: 72 * _pulseAnim.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.micActive
                                      .withOpacity(0.15 / _pulseAnim.value),
                                ),
                              ),
                            // Sound level ring
                            if (isListening)
                              Container(
                                width: 72 + (soundLevel * 20),
                                height: 72 + (soundLevel * 20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.micActive.withOpacity(0.4),
                                    width: 2,
                                  ),
                                ),
                              ),
                            // Core button
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isListening
                                    ? AppColors.micGradient
                                    : AppColors.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isListening
                                            ? AppColors.micActive
                                            : AppColors.primary)
                                        .withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isListening
                                    ? Icons.stop_rounded
                                    : Icons.mic_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Label
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                isListening ? 'Tap to stop' : 'Tap to speak',
                key: ValueKey(isListening),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isListening
                      ? AppColors.micActive
                      : (Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textSecondaryLight
                          : AppColors.textSecondaryDark),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
