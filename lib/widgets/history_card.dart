import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/translation_model.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';

class HistoryCard extends StatelessWidget {
  final TranslationModel translation;
  final VoidCallback onFavouriteTap;
  final VoidCallback onTap;

  const HistoryCard({
    super.key,
    required this.translation,
    required this.onFavouriteTap,
    required this.onTap,
  });

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: translation.isFavourite
                ? AppColors.accent.withOpacity(0.4)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: translation.isFavourite ? 1 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Language pair badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${translation.sourceLang.toUpperCase()} → ${translation.targetLang.toUpperCase()}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const Spacer(),

                // Timestamp
                Text(
                  _formatDate(translation.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                const SizedBox(width: 8),

                // Favourite button
                GestureDetector(
                  onTap: onFavouriteTap,
                  child: Icon(
                    translation.isFavourite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: translation.isFavourite
                        ? AppColors.accent
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Source text
            Text(
              translation.sourceText,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Divider with arrow
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    height: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_downward_rounded,
                    size: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    height: 16,
                  ),
                ),
              ],
            ),

            // Translated text
            Text(
              translation.translatedText,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),

            // Copy button
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: translation.translatedText),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.copy_rounded,
                      size: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text('Copy', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
