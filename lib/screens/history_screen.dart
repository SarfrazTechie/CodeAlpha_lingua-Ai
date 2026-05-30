import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/translation_provider.dart';
import '../models/translation_model.dart';
import '../theme/app_colors.dart';
import '../widgets/history_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<TranslationModel> _filtered(List<TranslationModel> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((t) {
      return t.sourceText.toLowerCase().contains(q) ||
          t.translatedText.toLowerCase().contains(q);
    }).toList();
  }

  void _exportAll(List<TranslationModel> list) {
    if (list.isEmpty) return;
    final buffer = StringBuffer();
    for (final t in list) {
      buffer.writeln('${t.sourceLang} → ${t.targetLang}');
      buffer.writeln('Original: ${t.sourceText}');
      buffer.writeln('Translated: ${t.translatedText}');
      buffer.writeln('---');
    }
    Share.share(buffer.toString(), subject: 'LinguaAI Translations');
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'This will delete all translation history. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TranslationProvider>().clearHistory();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TranslationProvider>();

    final allFiltered = _filtered(provider.history);
    final favFiltered = _filtered(provider.favourites);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History & Favourites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => _exportAll(
              _tabController.index == 0 ? allFiltered : favFiltered,
            ),
            tooltip: 'Export',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmClearHistory(context),
            tooltip: 'Clear history',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All (${provider.history.length})'),
            Tab(text: 'Favourites (${provider.favourites.length})'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search translations...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _HistoryList(
                  items: allFiltered,
                  provider: provider,
                  emptyMessage: 'No translations yet.\nStart translating!',
                  emptyIcon: '📝',
                ),
                _HistoryList(
                  items: favFiltered,
                  provider: provider,
                  emptyMessage:
                      'No favourites yet.\nStar a translation to save it!',
                  emptyIcon: '⭐',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<TranslationModel> items;
  final TranslationProvider provider;
  final String emptyMessage;
  final String emptyIcon;

  const _HistoryList({
    required this.items,
    required this.provider,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emptyIcon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final realIndex = provider.history.indexOf(item);

        return Dismissible(
          key: Key(item.timestamp.toIso8601String()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          onDismissed: (_) => provider.deleteHistoryItem(realIndex),
          child: HistoryCard(
            translation: item,
            onFavouriteTap: () => provider.toggleFavourite(realIndex),
            onTap: () => Navigator.pushNamed(
              context,
              '/word-detail',
              arguments: item.sourceText.trim().split(' ').first,
            ),
          ),
        );
      },
    );
  }
}
