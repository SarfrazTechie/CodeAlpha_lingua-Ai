import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/groq_service.dart';
import '../models/conversation_model.dart';

class GroqProvider extends ChangeNotifier {
  static const String _apiKeyPref = 'groq_api_key';

  final GroqService _groqService = GroqService();

  bool _isEnhancing = false;
  bool _isLoadingTips = false;
  bool _isReplying = false;

  String? _enhanceError;
  String? _tipsError;
  String? _replyError;

  Map<String, String>? _lastEnhancement;
  String? _lastGrammarTips;

  List<ConversationMessage> _conversationHistory = [];
  ConversationSession? _currentSession;

  // Getters
  bool get isEnhancing => _isEnhancing;
  bool get isLoadingTips => _isLoadingTips;
  bool get isReplying => _isReplying;

  String? get enhanceError => _enhanceError;
  String? get tipsError => _tipsError;
  String? get replyError => _replyError;

  Map<String, String>? get lastEnhancement => _lastEnhancement;
  String? get lastGrammarTips => _lastGrammarTips;

  List<ConversationMessage> get conversationHistory => _conversationHistory;
  ConversationSession? get currentSession => _currentSession;

  bool get hasApiKey => _groqService.hasApiKey;

  GroqProvider() {
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_apiKeyPref) ?? '';
    if (key.isNotEmpty) {
      _groqService.setApiKey(key);
      notifyListeners();
    }
  }

  Future<void> saveApiKey(String key) async {
    _groqService.setApiKey(key);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, key);
    notifyListeners();
  }

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref);
  }

  // AI Enhance translation
  Future<void> enhanceTranslation({
    required String sourceText,
    required String translatedText,
    required String sourceLang,
    required String targetLang,
  }) async {
    _isEnhancing = true;
    _enhanceError = null;
    _lastEnhancement = null;
    notifyListeners();

    try {
      _lastEnhancement = await _groqService.enhanceTranslation(
        sourceText: sourceText,
        translatedText: translatedText,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );
    } catch (e) {
      _enhanceError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isEnhancing = false;
      notifyListeners();
    }
  }

  // Grammar tips
  Future<void> loadGrammarTips({
    required String word,
    required String partOfSpeech,
  }) async {
    _isLoadingTips = true;
    _tipsError = null;
    _lastGrammarTips = null;
    notifyListeners();

    try {
      _lastGrammarTips = await _groqService.getGrammarTips(
        word: word,
        partOfSpeech: partOfSpeech,
      );
    } catch (e) {
      _tipsError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingTips = false;
      notifyListeners();
    }
  }

  // Start a new conversation session
  void startSession({
    required String scenario,
    required String userLang,
    required String targetLang,
    required String systemPrompt,
  }) {
    _conversationHistory = [];
    _currentSession = ConversationSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scenario: scenario,
      userLang: userLang,
      targetLang: targetLang,
      messages: [],
      createdAt: DateTime.now(),
    );
    _replyError = null;
    notifyListeners();
  }

  // Send message in conversation
  Future<void> sendMessage({
    required String userMessage,
    required String scenarioPrompt,
    required String targetLang,
    required String userLang,
  }) async {
    if (userMessage.trim().isEmpty) return;

    // Add user message
    final userMsg = ConversationMessage(
      content: userMessage,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
    _conversationHistory.add(userMsg);

    // Add loading placeholder
    final loadingMsg = ConversationMessage(
      content: '',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      isLoading: true,
    );
    _conversationHistory.add(loadingMsg);

    _isReplying = true;
    _replyError = null;
    notifyListeners();

    try {
      final reply = await _groqService.sendConversationMessage(
        history: _conversationHistory.where((m) => !m.isLoading).toList(),
        userMessage: userMessage,
        scenario: scenarioPrompt,
        targetLang: targetLang,
        userLang: userLang,
      );

      // Replace loading placeholder with real reply
      _conversationHistory.removeLast();
      _conversationHistory.add(
        ConversationMessage(
          content: reply,
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      _conversationHistory.removeLast();
      _replyError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isReplying = false;
      notifyListeners();
    }
  }

  void clearConversation() {
    _conversationHistory = [];
    _currentSession = null;
    _replyError = null;
    notifyListeners();
  }

  void clearEnhancement() {
    _lastEnhancement = null;
    _enhanceError = null;
    notifyListeners();
  }
}
