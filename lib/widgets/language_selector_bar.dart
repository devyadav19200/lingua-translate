import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../models/language_model.dart';
import '../core/app_colors.dart';
import 'language_picker_modal.dart';

class LanguageSelectorBar extends StatelessWidget {
  const LanguageSelectorBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<TranslationProvider>(
      builder: (context, provider, _) {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Source Language
              Expanded(
                child: _LanguageButton(
                  lang: provider.sourceLang,
                  onTap: () => _showSourcePicker(context, provider),
                  alignment: Alignment.centerLeft,
                ),
              ),
              // Swap Button
              _SwapButton(onTap: () => _swap(context, provider)),
              // Target Language
              Expanded(
                child: _LanguageButton(
                  lang: provider.targetLang,
                  onTap: () => _showTargetPicker(context, provider),
                  alignment: Alignment.centerRight,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSourcePicker(
      BuildContext context, TranslationProvider provider) async {
    final selected = await showModalBottomSheet<LanguageModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LanguagePickerModal(
        languages: provider.sourceLanguages,
        selectedLang: provider.sourceLang,
        title: 'Source Language',
      ),
    );
    if (selected != null) {
      provider.setSourceLanguage(selected);
    }
  }

  void _showTargetPicker(
      BuildContext context, TranslationProvider provider) async {
    final selected = await showModalBottomSheet<LanguageModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LanguagePickerModal(
        languages: provider.targetLanguages,
        selectedLang: provider.targetLang,
        title: 'Target Language',
      ),
    );
    if (selected != null) {
      provider.setTargetLanguage(selected);
    }
  }

  void _swap(BuildContext context, TranslationProvider provider) {
    provider.swapLanguages();
  }
}

class _LanguageButton extends StatelessWidget {
  final LanguageModel lang;
  final VoidCallback onTap;
  final Alignment alignment;

  const _LanguageButton({
    required this.lang,
    required this.onTap,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: alignment,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(lang.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                lang.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwapButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SwapButton({required this.onTap});

  @override
  State<_SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<_SwapButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _rotateAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _ctrl.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _rotateAnim,
          builder: (_, child) {
            return Transform.rotate(
              angle: _rotateAnim.value * 3.14159,
              child: child,
            );
          },
          child: const Icon(
            Icons.swap_horiz_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
