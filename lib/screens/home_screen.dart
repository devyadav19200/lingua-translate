import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../providers/history_provider.dart';
import '../providers/speech_provider.dart';
import '../providers/theme_provider.dart';
import '../models/translation_model.dart';
import '../core/app_colors.dart';
import '../widgets/language_selector_bar.dart';
import '../widgets/source_input_card.dart';
import '../widgets/translation_output_card.dart';
import '../widgets/mic_button.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnim;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabScaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _fabAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  void _onTranslateAndSave(BuildContext context) async {
    final translationProvider =
        context.read<TranslationProvider>();
    final historyProvider = context.read<HistoryProvider>();

    await translationProvider.translate();

    if (translationProvider.translatedText.isNotEmpty &&
        translationProvider.sourceText.isNotEmpty) {
      final model = TranslationModel(
        sourceText: translationProvider.sourceText,
        translatedText: translationProvider.translatedText,
        sourceLang: translationProvider.sourceLang.code,
        targetLang: translationProvider.targetLang.code,
        sourceLangName: translationProvider.sourceLang.name,
        targetLangName: translationProvider.targetLang.name,
      );
      await historyProvider.addToHistory(model);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.backgroundDark,
                    const Color(0xFF0D0D1F),
                  ]
                : [
                    const Color(0xFFF0F4FF),
                    AppColors.backgroundLight,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, isDark),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Language Selector Bar with swap button
                      const LanguageSelectorBar(),
                      const SizedBox(height: 16),
                      // Source Input Card
                      const SourceInputCard(),
                      const SizedBox(height: 12),
                      // Mic Button (centered, prominent)
                      const MicButton(),
                      const SizedBox(height: 12),
                      // Translation Output Card
                      const TranslationOutputCard(),
                      const SizedBox(height: 24),
                      // Translate Button
                      _buildTranslateButton(context),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Title
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.translate, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'LinguaTranslate',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
              ),
            ],
          ),
          // Action Buttons
          Row(
            children: [
              _AppBarIconButton(
                icon: Icons.history_rounded,
                tooltip: 'History',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HistoryScreen()),
                ),
              ),
              const SizedBox(width: 4),
              _AppBarIconButton(
                icon: Icons.settings_rounded,
                tooltip: 'Settings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SettingsScreen()),
                ),
              ),
              const SizedBox(width: 4),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return _AppBarIconButton(
                    icon: themeProvider.isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    tooltip: 'Toggle Theme',
                    onTap: () => themeProvider.toggleTheme(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTranslateButton(BuildContext context) {
    return Consumer<TranslationProvider>(
      builder: (context, provider, _) {
        return AnimatedBuilder(
          animation: _fabScaleAnim,
          builder: (context, child) {
            return Transform.scale(
              scale: _fabScaleAnim.value,
              child: child,
            );
          },
          child: GestureDetector(
            onTapDown: (_) => _fabAnimController.forward(),
            onTapUp: (_) {
              _fabAnimController.reverse();
              _onTranslateAndSave(context);
            },
            onTapCancel: () => _fabAnimController.reverse(),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: provider.isTranslating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.translate, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Translate',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _AppBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark.withOpacity(0.8)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.textLight : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
