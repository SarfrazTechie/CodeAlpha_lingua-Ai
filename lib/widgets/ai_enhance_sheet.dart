import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/groq_provider.dart';
import '../theme/app_colors.dart';

class AiEnhanceSheet extends StatefulWidget {
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;

  const AiEnhanceSheet({
    super.key,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
  });

  @override
  State<AiEnhanceSheet> createState() => _AiEnhanceSheetState();
}

class _AiEnhanceSheetState extends State<AiEnhanceSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroqProvider>().enhanceTranslation(
        sourceText: widget.sourceText,
        translatedText: widget.translatedText,
        sourceLang: widget.sourceLang,
        targetLang: widget.targetLang,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final groq = context.watch<GroqProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text('⚡', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Text(
                  'AI Enhance',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.groqOrangeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Groq',
                    style: TextStyle(
                      color: AppColors.groqOrangeText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: groq.isEnhancing
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.groqOrange,
                            ),
                            SizedBox(height: 16),
                            Text('Analyzing translation...'),
                          ],
                        ),
                      ),
                    )
                  : groq.enhanceError != null
                  ? _ErrorView(
                      error: groq.enhanceError!,
                      onRetry: () =>
                          context.read<GroqProvider>().enhanceTranslation(
                            sourceText: widget.sourceText,
                            translatedText: widget.translatedText,
                            sourceLang: widget.sourceLang,
                            targetLang: widget.targetLang,
                          ),
                    )
                  : groq.lastEnhancement != null
                  ? _EnhancementResult(enhancement: groq.lastEnhancement!)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnhancementResult extends StatelessWidget {
  final Map<String, String> enhancement;

  const _EnhancementResult({required this.enhancement});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced translation
        _ResultCard(
          label: '✨ Enhanced Translation',
          content: enhancement['enhanced'] ?? '',
          highlight: true,
        ),

        const SizedBox(height: 12),

        // Explanation
        if ((enhancement['explanation'] ?? '').isNotEmpty)
          _ResultCard(
            label: '💡 Why this translation',
            content: enhancement['explanation'] ?? '',
          ),

        const SizedBox(height: 12),

        // Formal / Casual
        Row(
          children: [
            Expanded(
              child: _ResultCard(
                label: '🎩 Formal',
                content: enhancement['formal'] ?? '',
                compact: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ResultCard(
                label: '😊 Casual',
                content: enhancement['casual'] ?? '',
                compact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String label;
  final String content;
  final bool highlight;
  final bool compact;

  const _ResultCard({
    required this.label,
    required this.content,
    this.highlight = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.groqOrange.withOpacity(0.08)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: highlight
            ? Border.all(
                color: AppColors.groqOrange.withOpacity(0.4),
                width: 0.5,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: highlight
                      ? AppColors.groqOrangeText
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: highlight ? FontWeight.w500 : null,
            ),
            maxLines: compact ? 3 : null,
            overflow: compact ? TextOverflow.ellipsis : null,
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
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.groqOrange,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
