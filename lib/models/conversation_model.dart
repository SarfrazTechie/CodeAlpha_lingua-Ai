enum MessageRole { user, assistant }

class ConversationMessage {
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final String? translatedContent;
  final bool isLoading;

  ConversationMessage({
    required this.content,
    required this.role,
    required this.timestamp,
    this.translatedContent,
    this.isLoading = false,
  });

  // Convert to Groq API format
  Map<String, dynamic> toApiJson() => {
    'role': role == MessageRole.user ? 'user' : 'assistant',
    'content': content,
  };

  ConversationMessage copyWith({
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    String? translatedContent,
    bool? isLoading,
  }) => ConversationMessage(
    content: content ?? this.content,
    role: role ?? this.role,
    timestamp: timestamp ?? this.timestamp,
    translatedContent: translatedContent ?? this.translatedContent,
    isLoading: isLoading ?? this.isLoading,
  );
}

class ConversationSession {
  final String id;
  final String scenario;
  final String userLang;
  final String targetLang;
  final List<ConversationMessage> messages;
  final DateTime createdAt;

  ConversationSession({
    required this.id,
    required this.scenario,
    required this.userLang,
    required this.targetLang,
    required this.messages,
    required this.createdAt,
  });

  ConversationSession copyWith({List<ConversationMessage>? messages}) =>
      ConversationSession(
        id: id,
        scenario: scenario,
        userLang: userLang,
        targetLang: targetLang,
        messages: messages ?? this.messages,
        createdAt: createdAt,
      );
}

// Predefined travel scenarios for AI role-play
class ConversationScenario {
  final String id;
  final String title;
  final String emoji;
  final String systemPrompt;

  const ConversationScenario({
    required this.id,
    required this.title,
    required this.emoji,
    required this.systemPrompt,
  });

  static const List<ConversationScenario> all = [
    ConversationScenario(
      id: 'free',
      title: 'Free chat',
      emoji: '💬',
      systemPrompt:
          'You are a friendly language tutor. Respond naturally in the target language, gently correct grammar mistakes, and keep conversations engaging.',
    ),
    ConversationScenario(
      id: 'restaurant',
      title: 'Restaurant',
      emoji: '🍽️',
      systemPrompt:
          'You are a waiter at a restaurant. Role-play taking orders, answering questions about the menu, and handling requests. Respond in the target language.',
    ),
    ConversationScenario(
      id: 'airport',
      title: 'Airport',
      emoji: '✈️',
      systemPrompt:
          'You are an airport staff member. Role-play check-in, boarding, and travel scenarios. Respond in the target language.',
    ),
    ConversationScenario(
      id: 'hotel',
      title: 'Hotel',
      emoji: '🏨',
      systemPrompt:
          'You are a hotel receptionist. Role-play check-in, room requests, and guest services. Respond in the target language.',
    ),
    ConversationScenario(
      id: 'shopping',
      title: 'Shopping',
      emoji: '🛍️',
      systemPrompt:
          'You are a shop assistant. Role-play helping customers find items, handling payments, and answering questions. Respond in the target language.',
    ),
  ];
}
