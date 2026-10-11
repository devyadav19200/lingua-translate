import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clipboard/clipboard.dart';
import '../providers/translation_provider.dart';
import '../providers/speech_provider.dart';
import '../providers/history_provider.dart';
import '../models/translation_model.dart';
import '../core/app_colors.dart';

class TranslationOutputCard extends StatelessWidget {
  const TranslationOutputCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<TranslationProvider, SpeechProvider>(
      builder: (context, translationProvider, speechProvider, _) {
        final hasTranslation = translationProvider.translatedText.isNotEmpty;
        final isTranslating = translationProvider.isTranslating;
        final hasError =
            translationProvider.state == TranslationState.error;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          constraints: const BoxConstraints(minHeight: 160),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: hasTranslation
                ? Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1.5,
                  )
                : null,
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
                      translationProvider.targetLang.flag,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      translationProvider.targetLang.name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    if (hasTranslation)
                      Row(
                        children: [
                          // Speak Button
                          _OutputActionButton(
                            icon: speechProvider.isTtsPlaying
                                ? Icons.stop_rounded
                                : Icons.volume_up_rounded,
                            color: speechProvider.isTtsPlaying
                                ? AppColors.error
                                : AppColors.primary,
                            tooltip: speechProvider.isTtsPlaying
                                ? 'Stop'
                                : 'Listen',
                            onTap: () {
                              if (speechProvider.isTtsPlaying) {
                                speechProvider.stopSpeaking();
                              } else {
                                speechProvider.speak(
                                  translationProvider.translatedText,
                                  languageCode:
                                      translationProvider.targetLang.code,
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          // Copy Button
                          _OutputActionButton(
                            icon: Icons.copy_rounded,
                            color: AppColors.primary,
                            tooltip: 'Copy',
                            onTap: () {
                              FlutterClipboard.copy(
                                  translationProvider.translatedText);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(children: [
                                    Icon(Icons.check_circle_rounded,
                                        color: Colors.white, size: 16),
                                    SizedBox(width: 8),
                                    Text(
                                      'Copied to clipboard!',
                                      style: TextStyle(fontFamily: 'Poppins'),
                                    ),
                                  ]),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.success,
                                  duration: const Duration(seconds: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          // Save to History
                          _OutputActionButton(
                            icon: Icons.bookmark_add_outlined,
                            color: AppColors.favorite,
                            tooltip: 'Save',
                            onTap: () async {
                              final model = TranslationModel(
                                sourceText: translationProvider.sourceText,
                                translatedText:
                                    translationProvider.translatedText,
                                sourceLang: translationProvider.sourceLang.code,
                                targetLang: translationProvider.targetLang.code,
                                sourceLangName:
                                    translationProvider.sourceLang.name,
                                targetLangName:
                                    translationProvider.targetLang.name,
                                isFavorite: true,
                              );
                              await context
                                  .read<HistoryProvider>()
                                  .addToHistory(model);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(children: [
                                      Icon(Icons.star_rounded,
                                          color: Colors.white, size: 16),
                                      SizedBox(width: 8),
                                      Text('Saved to favorites!',
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                    ]),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppColors.favorite,
                                    duration: const Duration(seconds: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildContent(context, translationProvider, isTranslating,
                    hasError, isDark),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    TranslationProvider provider,
    bool isTranslating,
    bool hasError,
    bool isDark,
  ) {
    if (isTranslating) {
      return _TranslatingShimmer(isDark: isDark);
    }

    if (hasError) {
      return Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              provider.errorMessage,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      );
    }

    if (provider.translatedText.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Icon(
              Icons.translate_rounded,
              size: 36,
              color: AppColors.primary.withOpacity(0.2),
            ),
            const SizedBox(height: 8),
            Text(
              'Translation will appear here',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryLight
                    : AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        provider.translatedText,
        key: ValueKey(provider.translatedText),
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textLight : AppColors.textDark,
          height: 1.6,
        ),
      ),
    );
  }
}

class _OutputActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _OutputActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

class _TranslatingShimmer extends StatefulWidget {
  final bool isDark;
  const _TranslatingShimmer({required this.isDark});

  @override
  State<_TranslatingShimmer> createState() => _TranslatingShimmerState();
}

class _TranslatingShimmerState extends State<_TranslatingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _shimmerLine(double width) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Container(
          width: width,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            gradient: LinearGradient(
              begin: Alignment(_anim.value - 1, 0),
              end: Alignment(_anim.value, 0),
              colors: widget.isDark
                  ? [
                      AppColors.surfaceDark2,
                      AppColors.dividerDark,
                      AppColors.surfaceDark2,
                    ]
                  : [
                      AppColors.surfaceLight2,
                      Colors.white,
                      AppColors.surfaceLight2,
                    ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmerLine(double.infinity),
        const SizedBox(height: 10),
        _shimmerLine(240),
        const SizedBox(height: 10),
        _shimmerLine(180),
      ],
    );
  }
}
