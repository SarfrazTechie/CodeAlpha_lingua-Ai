import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../theme/app_colors.dart';

class SynonymChip extends StatelessWidget {
  final String word;
  final bool isAntonym;

  const SynonymChip({super.key, required this.word, required this.isAntonym});

  @override
  Widget build(BuildContext context) {
    final color = isAntonym ? AppColors.error : AppColors.primary;

    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAntonym)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.remove_circle_outline_rounded,
                  size: 12,
                  color: color,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.add_circle_outline_rounded,
                  size: 12,
                  color: color,
                ),
              ),
            Text(
              word,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    // Tap a synonym to retranslate it instantly
    final provider = context.read<TranslationProvider>();
    provider.onSourceTextChanged(word);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Translating "$word"...'),
        duration: const Duration(seconds: 1),
      ),
    );

    // Navigate back to translator
    Navigator.popUntil(context, ModalRoute.withName('/home'));
  }
}
