import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/groq_provider.dart';
import '../providers/translation_provider.dart';
import '../models/conversation_model.dart';
import '../theme/app_colors.dart';
import '../widgets/chat_bubble.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});
  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ConversationScenario _selectedScenario = ConversationScenario.all.first;
  bool _sessionStarted = false;

  @override
  void dispose() { _inputController.dispose(); _scrollController.dispose(); super.dispose(); }

  void _startSession() {
    final tp = context.read<TranslationProvider>();
    context.read<GroqProvider>().startSession(scenario: _selectedScenario.title, userLang: tp.sourceLang, targetLang: tp.targetLang, systemPrompt: _selectedScenario.systemPrompt);
    setState(() => _sessionStarted = true);
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    final tp = context.read<TranslationProvider>();
    await context.read<GroqProvider>().sendMessage(userMessage: text, scenarioPrompt: _selectedScenario.systemPrompt, targetLang: tp.targetLang, userLang: tp.sourceLang);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  void _resetSession() { context.read<GroqProvider>().clearConversation(); setState(() => _sessionStarted = false); }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GroqProvider>();
    final tp = context.watch<TranslationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text('AI Chat', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF122E27) : const Color(0xFFE1F5EE),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? const Color(0xFF1D6B5A) : const Color(0xFF9FE1CB)),
            ),
            child: Text('${tp.sourceLangName} → ${tp.targetLangName}', style: TextStyle(fontSize: 10, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontWeight: FontWeight.w600)),
          ),
        ]),
        actions: [if (_sessionStarted) IconButton(icon: Icon(Icons.refresh_rounded, color: isDark ? const Color(0xFF3A7A68) : const Color(0xFF9FE1CB)), onPressed: _resetSession)],
      ),
      body: !gp.hasApiKey ? _NoApiKeyView() : !_sessionStarted
          ? _SetupView(selectedScenario: _selectedScenario, sourceLang: tp.sourceLangName, targetLang: tp.targetLangName, onScenarioChanged: (s) => setState(() => _selectedScenario = s), onStart: _startSession, isDark: isDark)
          : _ChatView(gp: gp, scrollController: _scrollController, inputController: _inputController, onSend: _sendMessage, targetLang: tp.targetLangName, isDark: isDark),
    );
  }
}

class _NoApiKeyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 60, height: 60, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(16)), child: const Center(child: Icon(Icons.bolt_rounded, color: AppColors.primary, size: 30))),
    const SizedBox(height: 16),
    Text('Groq API Key Required', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
    const SizedBox(height: 8),
    Text('Add your free Groq API key in Settings to use AI Conversation mode.', style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight), textAlign: TextAlign.center),
    const SizedBox(height: 24),
    SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => Navigator.pushNamed(context, '/settings'), icon: const Icon(Icons.settings_rounded), label: const Text('Go to Settings'))),
  ])));
}

class _SetupView extends StatelessWidget {
  final ConversationScenario selectedScenario;
  final String sourceLang, targetLang;
  final void Function(ConversationScenario) onScenarioChanged;
  final VoidCallback onStart;
  final bool isDark;

  const _SetupView({required this.selectedScenario, required this.sourceLang, required this.targetLang, required this.onScenarioChanged, required this.onStart, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final card2 = isDark ? const Color(0xFF122E27) : const Color(0xFFE1F5EE);
    final border2 = isDark ? const Color(0xFF1D6B5A) : const Color(0xFF9FE1CB);
    final bg2 = isDark ? AppColors.surfaceDark : Colors.white;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header card
        Container(
          width: double.infinity, padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: card2, borderRadius: BorderRadius.circular(14), border: Border.all(color: border2)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.smart_toy_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('AI Conversation', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                Text('Practice $targetLang with AI', style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
              ]),
            ]),
            const SizedBox(height: 10),
            Wrap(spacing: 6, children: ['Free chat', 'Restaurant', 'Airport'].map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(8), border: Border.all(color: border2)),
              child: Text(s, style: TextStyle(fontSize: 10, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
            )).toList()),
          ]),
        ),

        const SizedBox(height: 14),
        Text('CHOOSE SCENARIO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, letterSpacing: 0.8)),
        const SizedBox(height: 8),

        ...ConversationScenario.all.map((scenario) {
          final isSel = selectedScenario.id == scenario.id;
          return GestureDetector(
            onTap: () => onScenarioChanged(scenario),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isSel ? card2 : bg2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSel ? AppColors.primary : border, width: isSel ? 1.5 : 1),
              ),
              child: Row(children: [
                Text(scenario.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(child: Text(scenario.title, style: TextStyle(fontSize: 13, fontWeight: isSel ? FontWeight.w700 : FontWeight.w400, color: isSel ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight) : const Color(0xFF6B7280)))),
                if (isSel) const Icon(Icons.check_rounded, color: AppColors.primary, size: 16),
              ]),
            ),
          );
        }),

        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onStart,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('▶  Start Conversation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}

class _ChatView extends StatelessWidget {
  final GroqProvider gp;
  final ScrollController scrollController;
  final TextEditingController inputController;
  final VoidCallback onSend;
  final String targetLang;
  final bool isDark;

  const _ChatView({required this.gp, required this.scrollController, required this.inputController, required this.onSend, required this.targetLang, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final messages = gp.conversationHistory;
    return Column(children: [
      Container(
        width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isDark ? const Color(0xFF122E27) : const Color(0xFFE1F5EE),
        child: Text('⚡ Practicing $targetLang · llama-3.3-70b via Groq', style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
      ),
      Expanded(
        child: messages.isEmpty
            ? Center(child: Text('Say something to start practicing!', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13)))
            : ListView.builder(controller: scrollController, padding: const EdgeInsets.all(14), itemCount: messages.length, itemBuilder: (context, i) => ChatBubble(message: messages[i])),
      ),
      if (gp.replyError != null) Container(width: double.infinity, padding: const EdgeInsets.all(10), color: AppColors.error.withOpacity(0.1), child: Text(gp.replyError!, style: const TextStyle(color: AppColors.error, fontSize: 12), textAlign: TextAlign.center)),
      Container(
        padding: EdgeInsets.only(left: 14, right: 8, top: 10, bottom: MediaQuery.of(context).viewInsets.bottom + 10),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5))),
        child: Row(children: [
          Expanded(child: TextField(controller: inputController, maxLines: 3, minLines: 1, textInputAction: TextInputAction.send, onSubmitted: (_) => onSend(), decoration: const InputDecoration(hintText: 'Type a message...', contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)))),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: gp.isReplying ? null : onSend,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: const CircleBorder(), padding: const EdgeInsets.all(13), minimumSize: Size.zero),
            child: gp.isReplying ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
          ),
        ]),
      ),
    ]);
  }
}
