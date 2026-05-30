import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/conversation_model.dart';

class GroqService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  String? _apiKey;

  void setApiKey(String key) {
    _apiKey = key.trim();
  }

  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  // Core request method
  Future<String> _sendRequest(List<Map<String, dynamic>> messages) async {
    if (!hasApiKey) {
      throw Exception('Groq API key not set. Please add it in Settings.');
    }

    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': messages,
              'max_tokens': 1024,
              'temperature': 0.3,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else if (response.statusCode == 401) {
        throw Exception(
          'Invalid Groq API key. Please check your key in Settings.',
        );
      } else if (response.statusCode == 429) {
        throw Exception('Groq rate limit reached. Please try again shortly.');
      } else {
        throw Exception('Groq API error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // AI Enhance — context-aware retranslation with explanation
  Future<Map<String, String>> enhanceTranslation({
    required String sourceText,
    required String translatedText,
    required String sourceLang,
    required String targetLang,
  }) async {
    final messages = [
      {
        'role': 'system',
        'content':
            'You are an expert linguist and translator. When given a translation, you provide: '
            '1) An enhanced, natural-sounding translation '
            '2) A brief explanation of why certain phrases translate the way they do '
            '3) A formal alternative and a casual alternative. '
            'Always respond in this exact JSON format: '
            '{"enhanced": "...", "explanation": "...", "formal": "...", "casual": "..."}',
      },
      {
        'role': 'user',
        'content':
            'Source ($sourceLang): "$sourceText"\nCurrent translation ($targetLang): "$translatedText"\n\nPlease enhance this translation.',
      },
    ];

    final result = await _sendRequest(messages);

    try {
      // Strip possible markdown code fences
      final cleaned = result
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      return {
        'enhanced': json['enhanced'] ?? translatedText,
        'explanation': json['explanation'] ?? '',
        'formal': json['formal'] ?? '',
        'casual': json['casual'] ?? '',
      };
    } catch (_) {
      return {
        'enhanced': translatedText,
        'explanation': result,
        'formal': '',
        'casual': '',
      };
    }
  }

  // Grammar tips for Word Detail screen
  Future<String> getGrammarTips({
    required String word,
    required String partOfSpeech,
  }) async {
    final messages = [
      {
        'role': 'system',
        'content':
            'You are a helpful English language teacher. Give concise, practical grammar tips '
            'about the given word. Include common mistakes learners make and cultural usage notes. '
            'Keep it under 150 words.',
      },
      {
        'role': 'user',
        'content':
            'Give me grammar tips for the word "$word" (used as $partOfSpeech).',
      },
    ];

    return await _sendRequest(messages);
  }

  // AI Conversation — bilingual chat
  Future<String> sendConversationMessage({
    required List<ConversationMessage> history,
    required String userMessage,
    required String scenario,
    required String targetLang,
    required String userLang,
  }) async {
    final systemPrompt = 'You are a friendly language practice partner helping user practice $targetLang. Respond ONLY in $targetLang. Keep replies short. NEVER say "by the way", "I noticed", "you mentioned", "you said". Just reply naturally to what user said.';
    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...history.map((m) => m.toApiJson()),
      {'role': 'user', 'content': userMessage},
    ];

    return await _sendRequest(messages);
  }
}
