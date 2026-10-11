import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../providers/speech_provider.dart';
import '../core/app_colors.dart';

class SourceInputCard extends StatefulWidget {
  const SourceInputCard({super.key});

  @override
  State<SourceInputCard> createState() => _SourceInputCardState();
}

class _SourceInputCardState extends State<SourceInputCard> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<TranslationProvider, SpeechProvider>(
      builder: (context, translationProvider, speechProvider, _) {
        // Sync text from speech
        if (speechProvider.isListening ||
            translationProvider.sourceText != _controller.text) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_controller.text != translationProvider.sourceText) {
              _controller.value = TextEditingValue(
                text: translationProvider.sourceText,
                selection: TextSelection.collapsed(
                    offset: translationProvider.sourceText.length),
              );
            }
          });
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isFocused
                  ? AppColors.primary.withOpacity(0.6)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.07),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  children: [
                    Text(
                      translationProvider.sourceLang.flag,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      translationProvider.sourceLang.name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    if (translationProvider.sourceText.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          translationProvider.clearAll();
                          _controller.clear();
                        },
                        child: Icon(
                          Icons.cancel_rounded,
                          size: 18,
                          color: isDark
                              ? AppColors.textSecondaryLight
                              : AppColors.textSecondaryDark,
                        ),
                      ),
                  ],
                ),
              ),
              // Text Input
              Focus(
                onFocusChange: (f) => setState(() => _isFocused = f),
                child: TextField(
                  controller: _controller,
                  maxLines: 5,
                  minLines: 4,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter text to translate...',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: isDark
                          ? AppColors.textSecondaryLight
                          : AppColors.textSecondaryDark,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    fillColor: Colors.transparent,
                    filled: false,
                  ),
                  onChanged: translationProvider.updateSourceText,
                ),
              ),
              // Char count
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    if (speechProvider.isListening)
                      _ListeningIndicator(),
                    const Spacer(),
                    Text(
                      '${translationProvider.sourceText.length}/5000',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: translationProvider.sourceText.length > 4500
                            ? AppColors.error
                            : (isDark
                                ? AppColors.textSecondaryLight
                                : AppColors.textSecondaryDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ListeningIndicator extends StatefulWidget {
  @override
  State<_ListeningIndicator> createState() => _ListeningIndicatorState();
}

class _ListeningIndicatorState extends State<_ListeningIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.micActive,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Listening...',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppColors.micActive,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
