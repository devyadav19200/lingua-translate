import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../providers/translation_provider.dart';
import '../providers/speech_provider.dart';
import '../models/translation_model.dart';
import '../core/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:clipboard/clipboard.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TranslationModel> _filtered(List<TranslationModel> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list
        .where((t) =>
            t.sourceText.toLowerCase().contains(q) ||
            t.translatedText.toLowerCase().contains(q) ||
            t.sourceLangName.toLowerCase().contains(q) ||
            t.targetLangName.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<HistoryProvider>(
            builder: (context, provider, _) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(children: [
                      Icon(Icons.delete_sweep_rounded, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Clear All'),
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'clear_non_favorites',
                    child: Row(children: [
                      Icon(Icons.star_outline_rounded, color: AppColors.warning),
                      SizedBox(width: 8),
                      Text('Keep Favorites Only'),
                    ]),
                  ),
                ],
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Favorites ⭐'),
          ],
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search translations...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              ),
            ),
          ),
          // Tab Views
          Expanded(
            child: Consumer<HistoryProvider>(
              builder: (context, provider, _) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(context, _filtered(provider.history)),
                    _buildList(context, _filtered(provider.favorites)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<TranslationModel> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 72,
              color: AppColors.primary.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No results found'
                  : 'No translations yet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, i) => _HistoryCard(
        item: items[i],
        onFavorite: () =>
            context.read<HistoryProvider>().toggleFavorite(items[i].id),
        onDelete: () =>
            context.read<HistoryProvider>().deleteItem(items[i].id),
        onReuse: () => _reuseTranslation(context, items[i]),
        onSpeak: () => context.read<SpeechProvider>().speak(
              items[i].translatedText,
              languageCode: items[i].targetLang,
            ),
      ),
    );
  }

  void _reuseTranslation(BuildContext context, TranslationModel item) {
    final provider = context.read<TranslationProvider>();
    // Load languages and text
    final srcLang = provider.sourceLanguages.firstWhere(
      (l) => l.code == item.sourceLang,
      orElse: () => provider.sourceLanguages.first,
    );
    final tgtLang = provider.targetLanguages.firstWhere(
      (l) => l.code == item.targetLang,
      orElse: () => provider.targetLanguages.first,
    );
    provider.setSourceLanguage(srcLang);
    provider.setTargetLanguage(tgtLang);
    provider.updateSourceText(item.sourceText);
    Navigator.pop(context);
  }

  void _handleMenuAction(BuildContext context, String action) async {
    final provider = context.read<HistoryProvider>();
    if (action == 'clear_all') {
      final confirm = await _showConfirmDialog(
        context,
        'Clear All History?',
        'This will delete all translation history.',
      );
      if (confirm == true) await provider.clearHistory();
    } else if (action == 'clear_non_favorites') {
      final confirm = await _showConfirmDialog(
        context,
        'Keep Favorites Only?',
        'All non-favorited translations will be deleted.',
      );
      if (confirm == true) await provider.clearNonFavorites();
    }
  }

  Future<bool?> _showConfirmDialog(
      BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final TranslationModel item;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;
  final VoidCallback onReuse;
  final VoidCallback onSpeak;

  const _HistoryCard({
    required this.item,
    required this.onFavorite,
    required this.onDelete,
    required this.onReuse,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = DateFormat('MMM d, y • HH:mm').format(item.timestamp);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onReuse,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Language bar
                Row(
                  children: [
                    Text(
                      '${item.sourceLangName} → ${item.targetLangName}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: isDark
                            ? AppColors.textSecondaryLight
                            : AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Source text
                Text(
                  item.sourceText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                // Divider
                Divider(
                  color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                  height: 16,
                ),
                // Translated text
                Text(
                  item.translatedText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                // Action row
                Row(
                  children: [
                    _ActionChip(
                      icon: Icons.volume_up_rounded,
                      onTap: onSpeak,
                    ),
                    const SizedBox(width: 8),
                    _ActionChip(
                      icon: Icons.copy_rounded,
                      onTap: () {
                        FlutterClipboard.copy(item.translatedText);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard!'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _ActionChip(
                      icon: Icons.redo_rounded,
                      label: 'Reuse',
                      onTap: onReuse,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onFavorite,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          item.isFavorite
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          key: ValueKey(item.isFavorite),
                          color: item.isFavorite
                              ? AppColors.favorite
                              : isDark
                                  ? AppColors.textSecondaryLight
                                  : AppColors.textSecondaryDark,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.primarySoft,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
