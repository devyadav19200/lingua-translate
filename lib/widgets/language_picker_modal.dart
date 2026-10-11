import 'package:flutter/material.dart';
import '../models/language_model.dart';
import '../core/app_colors.dart';

class LanguagePickerModal extends StatefulWidget {
  final List<LanguageModel> languages;
  final LanguageModel selectedLang;
  final String title;

  const LanguagePickerModal({
    super.key,
    required this.languages,
    required this.selectedLang,
    required this.title,
  });

  @override
  State<LanguagePickerModal> createState() => _LanguagePickerModalState();
}

class _LanguagePickerModalState extends State<LanguagePickerModal> {
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();

  List<LanguageModel> get _filtered {
    if (_search.isEmpty) return widget.languages;
    final q = _search.toLowerCase();
    return widget.languages
        .where((l) =>
            l.name.toLowerCase().contains(q) ||
            l.code.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close_rounded,
                    color: isDark
                        ? AppColors.textSecondaryLight
                        : AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search language...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Language List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              physics: const BouncingScrollPhysics(),
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final lang = _filtered[i];
                final isSelected = lang.code == widget.selectedLang.code;
                return ListTile(
                  onTap: () => Navigator.pop(context, lang),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: isSelected
                      ? (isDark
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.primarySoft)
                      : null,
                  leading: Text(lang.flag, style: const TextStyle(fontSize: 22)),
                  title: Text(
                    lang.name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.textLight : AppColors.textDark),
                    ),
                  ),
                  subtitle: Text(
                    lang.code.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondaryLight
                          : AppColors.textSecondaryDark,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
