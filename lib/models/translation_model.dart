class TranslationModel {
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final DateTime timestamp;
  bool isFavourite;

  TranslationModel({
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.timestamp,
    this.isFavourite = false,
  });

  Map<String, dynamic> toJson() => {
    'sourceText': sourceText,
    'translatedText': translatedText,
    'sourceLang': sourceLang,
    'targetLang': targetLang,
    'timestamp': timestamp.toIso8601String(),
    'isFavourite': isFavourite,
  };

  factory TranslationModel.fromJson(Map<String, dynamic> json) =>
      TranslationModel(
        sourceText: json['sourceText'],
        translatedText: json['translatedText'],
        sourceLang: json['sourceLang'],
        targetLang: json['targetLang'],
        timestamp: DateTime.parse(json['timestamp']),
        isFavourite: json['isFavourite'] ?? false,
      );
}
