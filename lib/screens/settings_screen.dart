import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/groq_provider.dart';
import '../providers/translation_provider.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _obscureKey = true;

  @override
  void initState() { super.initState(); _loadApiKey(); }

  Future<void> _loadApiKey() async {
    final key = await context.read<GroqProvider>().getApiKey();
    if (key != null) _apiKeyController.text = key;
  }

  @override
  void dispose() { _apiKeyController.dispose(); super.dispose(); }

  void _saveApiKey() async {
    await context.read<GroqProvider>().saveApiKey(_apiKeyController.text.trim());
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API key saved!')));
  }

  void _confirmClear() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Clear History'),
      content: const Text('Delete all translation history?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () { context.read<TranslationProvider>().clearHistory(); Navigator.pop(context); }, style: FilledButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Clear')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final gp = context.watch<GroqProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.surfaceDark : Colors.white;
    final card2 = isDark ? const Color(0xFF122E27) : const Color(0xFFE1F5EE);
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final setRowBorder = isDark ? const Color(0xFF0A1F1C) : const Color(0xFFF0FBF9);

    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: Theme.of(context).textTheme.titleLarge)),
      body: ListView(children: [
        _SectLbl('Appearance', isDark: isDark),

        // Dark mode row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: setRowBorder))),
          child: Row(children: [
            Container(width: 28, height: 28, decoration: BoxDecoration(color: card2, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.dark_mode_rounded, size: 15, color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Dark Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              Text(isDark ? 'Currently dark' : 'Currently light', style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
            ])),
            GestureDetector(
              onTap: () => tp.setTheme(tp.isDark ? ThemeMode.light : ThemeMode.dark),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 36, height: 20,
                decoration: BoxDecoration(color: tp.isDark ? AppColors.primary : const Color(0xFF9FE1CB), borderRadius: BorderRadius.circular(10)),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  alignment: tp.isDark ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(margin: const EdgeInsets.all(3), width: 14, height: 14, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                ),
              ),
            ),
          ]),
        ),

        // Text size row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: setRowBorder))),
          child: Row(children: [
            Container(width: 28, height: 28, decoration: BoxDecoration(color: card2, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.text_fields_rounded, size: 15, color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Text Size', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              const Text('Medium', style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
            ])),
            Icon(Icons.chevron_right_rounded, color: isDark ? const Color(0xFF3A7A68) : const Color(0xFF9FE1CB), size: 18),
          ]),
        ),

        _SectLbl('Groq AI', isDark: isDark),

        // API Key card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('API Key', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              const SizedBox(width: 8),
              if (gp.hasApiKey)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF052e16) : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? const Color(0xFF1D6B5A) : const Color(0xFF6EE7B7)),
                  ),
                  child: Text('✓ Connected', style: TextStyle(color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46), fontSize: 10, fontWeight: FontWeight.w600)),
                ),
            ]),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : const Color(0xFFF8FFFE), borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
              child: Row(children: [
                Expanded(child: TextField(controller: _apiKeyController, obscureText: _obscureKey, decoration: const InputDecoration(border: InputBorder.none, filled: false, hintText: 'gsk_...', contentPadding: EdgeInsets.zero, isDense: true))),
                GestureDetector(onTap: () => setState(() => _obscureKey = !_obscureKey), child: Icon(_obscureKey ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 16, color: isDark ? const Color(0xFF3A7A68) : const Color(0xFF9FE1CB))),
              ]),
            ),
            const SizedBox(height: 6),
            Text('Get free key at console.groq.com', style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saveApiKey,
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Save API Key', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
          ]),
        ),

        _SectLbl('Data', isDark: isDark),

        GestureDetector(
          onTap: _confirmClear,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: setRowBorder))),
            child: Row(children: [
              Container(width: 28, height: 28, decoration: const BoxDecoration(color: Color(0xFFFEF2F2), borderRadius: BorderRadius.all(Radius.circular(8))), child: const Icon(Icons.delete_outline_rounded, size: 15, color: Color(0xFFDC2626))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Clear History', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                const Text('Delete translations', style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
              ])),
              Icon(Icons.chevron_right_rounded, color: isDark ? const Color(0xFF3A7A68) : const Color(0xFF9FE1CB), size: 18),
            ]),
          ),
        ),

        _SectLbl('About', isDark: isDark),

        _AboutRow(icon: Icons.info_outline_rounded, title: 'LinguaAI v1.0.0', subtitle: 'CodeAlpha Task 1', isDark: isDark, card2: card2),
        _AboutRow(icon: Icons.bolt_rounded, title: 'AI Features', subtitle: 'Groq · llama-3.3-70b', isDark: isDark, card2: card2, isLast: true),

        const SizedBox(height: 32),
      ]),
    );
  }
}

class _SectLbl extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectLbl(this.title, {required this.isDark});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
    child: Text(title.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFF3A7A68) : const Color(0xFF5DCAA5), letterSpacing: 0.8)),
  );
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool isDark;
  final Color card2;
  final bool isLast;
  const _AboutRow({required this.icon, required this.title, required this.subtitle, required this.isDark, required this.card2, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final setRowBorder = isDark ? const Color(0xFF0A1F1C) : const Color(0xFFF0FBF9);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: setRowBorder))),
      child: Row(children: [
        Container(width: 28, height: 28, decoration: BoxDecoration(color: card2, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 15, color: AppColors.primary)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
        ]),
      ]),
    );
  }
}
