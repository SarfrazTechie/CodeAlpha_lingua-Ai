import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/translation_provider.dart';
import '../providers/groq_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/language_picker.dart';
import '../widgets/ai_enhance_sheet.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});
  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _inputController = TextEditingController();
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
    setState(() {});
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) return;
    await _speech.listen(onResult: (result) {
      _inputController.text = result.recognizedWords;
      context.read<TranslationProvider>().onSourceTextChanged(result.recognizedWords);
    });
    setState(() => _isListening = true);
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _speak(String text, String lang) async {
    await _tts.setLanguage(lang);
    await _tts.speak(text);
  }

  void _showEnhanceSheet() {
    final p = context.read<TranslationProvider>();
    if (p.sourceText.isEmpty || p.translatedText.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiEnhanceSheet(sourceText: p.sourceText, translatedText: p.translatedText, sourceLang: p.sourceLang, targetLang: p.targetLang),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _speech.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TranslationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.surfaceDark : Colors.white;
    final card2 = isDark ? const Color(0xFF122E27) : const Color(0xFFE1F5EE);
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final border2 = isDark ? const Color(0xFF1D6B5A) : const Color(0xFF9FE1CB);

    return Scaffold(
      appBar: AppBar(
        title: Text('Translator', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(icon: Icon(Icons.history_rounded, color: isDark ? const Color(0xFF3A7A68) : const Color(0xFF9FE1CB)), onPressed: () => Navigator.pushNamed(context, '/history')),
          IconButton(icon: Icon(Icons.star_border_rounded, color: isDark ? const Color(0xFF3A7A68) : const Color(0xFF9FE1CB)), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F2822) : const Color(0xFFF0FBF9),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: border2),
                    ),
                    child: LanguagePicker(selected: p.sourceLang, onChanged: p.setSourceLang, label: 'From'),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () { p.swapLanguages(); _inputController.text = p.sourceText; },
                  child: Container(width: 34, height: 34, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 18)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F2822) : const Color(0xFFF0FBF9),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: border2),
                    ),
                    child: LanguagePicker(selected: p.targetLang, onChanged: p.setTargetLang, label: 'To'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Input card
            Container(
              decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
              child: Column(
                children: [
                  TextField(
                    controller: _inputController,
                    maxLines: 4, minLines: 3,
                    style: TextStyle(fontSize: 13, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    decoration: InputDecoration(
                      hintText: 'Enter text to translate...',
                      hintStyle: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      border: InputBorder.none, filled: false,
                      contentPadding: const EdgeInsets.all(14),
                      suffixIcon: _inputController.text.isNotEmpty
                          ? IconButton(icon: Icon(Icons.clear_rounded, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight), onPressed: () { _inputController.clear(); p.clearInput(); })
                          : null,
                    ),
                    onChanged: p.onSourceTextChanged,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: border, width: 0.5))),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _speechAvailable ? (_isListening ? _stopListening : _startListening) : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _isListening ? AppColors.error.withOpacity(0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _isListening ? AppColors.error : Colors.transparent, width: 1.5),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              _isListening ? const _PulsingMic() : Icon(Icons.mic_none_rounded, color: isDark ? const Color(0xFF3A7A68) : const Color(0xFF9FE1CB), size: 18),
                              if (_isListening) ...[const SizedBox(width: 5), const Text('Listening...', style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600))],
                            ]),
                          ),
                        ),
                        if (p.sourceText.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          GestureDetector(onTap: () => _speak(_inputController.text, p.sourceLang), child: Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 18)),
                        ],
                        const Spacer(),
                        Text('${p.sourceText.length} / 500', style: TextStyle(fontSize: 10, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Output card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: card2, borderRadius: BorderRadius.circular(14), border: Border.all(color: border2)),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (p.isTranslating)
                    Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)))
                  else if (p.error != null)
                    Text(p.error!, style: const TextStyle(color: AppColors.error, fontSize: 13))
                  else ...[
                    if (p.translatedText.isNotEmpty) ...[
                      Text(p.translatedText, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      const SizedBox(height: 4),
                    ],
                    if (p.translatedText.isEmpty)
                      Text('Translation will appear here...', style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  ],
                  if (p.translatedText.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _IcoBtn(icon: Icons.volume_up_rounded, onTap: () => _speak(p.translatedText, p.targetLang), isDark: isDark),
                        _IcoBtn(icon: Icons.copy_rounded, onTap: () { Clipboard.setData(ClipboardData(text: p.translatedText)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!'))); }, isDark: isDark),
                        _IcoBtn(icon: Icons.share_rounded, onTap: () => Share.share(p.translatedText), isDark: isDark),
                        _IcoBtn(icon: Icons.favorite_border_rounded, onTap: () => Navigator.pushNamed(context, '/word-detail', arguments: p.sourceText.trim().split(' ').first), isDark: isDark),
                        const Spacer(),
                        GestureDetector(
                          onTap: _showEnhanceSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(7)),
                            child: const Text('✦ Enhance', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Phrases
            Text('QUICK PHRASES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, letterSpacing: 0.8)),
            const SizedBox(height: 10),
            _QuickPhrases(isDark: isDark, onPhraseTap: (phrase) { _inputController.text = phrase; p.onSourceTextChanged(phrase); }),
          ],
        ),
      ),
    );
  }
}

class _IcoBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  const _IcoBtn({required this.icon, required this.onTap, required this.isDark});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(padding: const EdgeInsets.all(4), child: Icon(icon, size: 19, color: isDark ? const Color(0xFF3A7A68) : const Color(0xFF9FE1CB))),
  );
}

class _PulsingMic extends StatefulWidget {
  const _PulsingMic();
  @override
  State<_PulsingMic> createState() => _PulsingMicState();
}
class _PulsingMicState extends State<_PulsingMic> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true); _a = Tween<double>(begin: 0.8, end: 1.3).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: _a, builder: (_, __) => Stack(alignment: Alignment.center, children: [Transform.scale(scale: _a.value, child: Container(width: 26, height: 26, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.error.withOpacity(0.2)))), const Icon(Icons.mic_rounded, color: AppColors.error, size: 18)]));
}

class _QuickPhrases extends StatelessWidget {
  final bool isDark;
  final void Function(String) onPhraseTap;
  const _QuickPhrases({required this.isDark, required this.onPhraseTap});

  static const Map<String, List<String>> _phrases = {
    '✈️ Travel': ['Airport?', 'I need help', 'How much?', 'Doctor'],
    '👋 Greetings': ['Good morning', 'Thank you', 'Please', 'Hello!'],
    '🏥 Medical': ['I need a doctor', 'Call an ambulance', 'I am allergic to...'],
    '💼 Business': ['Nice to meet you', 'Schedule a meeting?', 'Send the report'],
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _phrases.entries.map((entry) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.key, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFF3A7A68) : const Color(0xFF9FE1CB))),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: entry.value.map((phrase) => GestureDetector(
            onTap: () => onPhraseTap(phrase),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF122E27) : const Color(0xFFF0FBF9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF1D6B5A) : const Color(0xFF9FE1CB)),
              ),
              child: Text(phrase, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
            ),
          )).toList()),
          const SizedBox(height: 14),
        ],
      )).toList(),
    );
  }
}
