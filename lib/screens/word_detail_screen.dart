import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/dictionary_service.dart';
import '../models/word_model.dart';
import '../providers/groq_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/synonym_chip.dart';

class WordDetailScreen extends StatefulWidget {
  const WordDetailScreen({super.key});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  final DictionaryService _dictionaryService = DictionaryService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  WordModel? _word;
  bool _isLoading = true;
  String? _error;
  bool _grammarExpanded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final word = ModalRoute.of(context)?.settings.arguments as String?;
    if (word != null) _loadWord(word);
  }

  Future<void> _loadWord(String word) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _dictionaryService.lookupWord(word);
      setState(() {
        _word = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _playAudio(String url) async {
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (_) {}
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(_word?.word ?? 'Word Detail')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorView(
              error: _error!,
              onRetry: () {
                final word =
                    ModalRoute.of(context)?.settings.arguments as String?;
                if (word != null) _loadWord(word);
              },
            )
          : _word == null
          ? const _NotFoundView()
          : _WordContent(
              word: _word!,
              isDark: isDark,
              onPlayAudio: _playAudio,
              grammarExpanded: _grammarExpanded,
              onToggleGrammar: () =>
                  setState(() => _grammarExpanded = !_grammarExpanded),
            ),
    );
  }
}

class _WordContent extends StatelessWidget {
  final WordModel word;
  final bool isDark;
  final void Function(String) onPlayAudio;
  final bool grammarExpanded;
  final VoidCallback onToggleGrammar;

  const _WordContent({
    required this.word,
    required this.isDark,
    required this.onPlayAudio,
    required this.grammarExpanded,
    required this.onToggleGrammar,
  });

  @override
  Widget build(BuildContext context) {
    final groqProvider = context.watch<GroqProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.accent.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.word,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                if (word.phoneticText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    word.phoneticText!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (word.audioUrl != null) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => onPlayAudio(word.audioUrl!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.volume_up_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Listen',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Meanings
          ...word.meanings.map((meaning) => _MeaningSection(meaning: meaning)),

          // Synonyms
          if (word.allSynonyms.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Synonyms', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: word.allSynonyms
                  .take(12)
                  .map((s) => SynonymChip(word: s, isAntonym: false))
                  .toList(),
            ),
          ],

          // Antonyms
          if (word.allAntonyms.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Antonyms', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: word.allAntonyms
                  .take(12)
                  .map((s) => SynonymChip(word: s, isAntonym: true))
                  .toList(),
            ),
          ],

          const SizedBox(height: 24),

          // AI Grammar tips section
          _GrammarTipsSection(
            word: word,
            groqProvider: groqProvider,
            expanded: grammarExpanded,
            onToggle: onToggleGrammar,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _MeaningSection extends StatelessWidget {
  final Meaning meaning;

  const _MeaningSection({required this.meaning});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Part of speech badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              meaning.partOfSpeech,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...meaning.definitions
              .take(3)
              .map(
                (def) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6, right: 8),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              def.definition,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      if (def.example != null) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Text(
                            '"${def.example}"',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _GrammarTipsSection extends StatelessWidget {
  final WordModel word;
  final GroqProvider groqProvider;
  final bool expanded;
  final VoidCallback onToggle;

  const _GrammarTipsSection({
    required this.word,
    required this.groqProvider,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final partOfSpeech = word.meanings.isNotEmpty
        ? word.meanings.first.partOfSpeech
        : 'word';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.groqOrangeBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.groqOrange.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Header tap to expand
          InkWell(
            onTap: () {
              onToggle();
              if (!expanded && groqProvider.lastGrammarTips == null) {
                context.read<GroqProvider>().loadGrammarTips(
                  word: word.word,
                  partOfSpeech: partOfSpeech,
                );
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'AI Grammar Tips',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.groqOrangeText,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.groqOrangeText,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (expanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: groqProvider.isLoadingTips
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(
                          color: AppColors.groqOrange,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : groqProvider.tipsError != null
                  ? Text(
                      groqProvider.tipsError!,
                      style: const TextStyle(color: AppColors.error),
                    )
                  : groqProvider.lastGrammarTips != null
                  ? Text(
                      groqProvider.lastGrammarTips!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.groqOrangeText,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📖', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('Word not found in dictionary'),
        ],
      ),
    );
  }
}
