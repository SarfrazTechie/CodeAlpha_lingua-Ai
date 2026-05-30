class Phonetic {
  final String? text;
  final String? audio;

  Phonetic({this.text, this.audio});

  factory Phonetic.fromJson(Map<String, dynamic> json) =>
      Phonetic(text: json['text'], audio: json['audio']);
}

class Definition {
  final String definition;
  final String? example;
  final List<String> synonyms;
  final List<String> antonyms;

  Definition({
    required this.definition,
    this.example,
    this.synonyms = const [],
    this.antonyms = const [],
  });

  factory Definition.fromJson(Map<String, dynamic> json) => Definition(
    definition: json['definition'] ?? '',
    example: json['example'],
    synonyms: List<String>.from(json['synonyms'] ?? []),
    antonyms: List<String>.from(json['antonyms'] ?? []),
  );
}

class Meaning {
  final String partOfSpeech;
  final List<Definition> definitions;
  final List<String> synonyms;
  final List<String> antonyms;

  Meaning({
    required this.partOfSpeech,
    required this.definitions,
    this.synonyms = const [],
    this.antonyms = const [],
  });

  factory Meaning.fromJson(Map<String, dynamic> json) => Meaning(
    partOfSpeech: json['partOfSpeech'] ?? '',
    definitions: (json['definitions'] as List<dynamic>? ?? [])
        .map((d) => Definition.fromJson(d))
        .toList(),
    synonyms: List<String>.from(json['synonyms'] ?? []),
    antonyms: List<String>.from(json['antonyms'] ?? []),
  );
}

class WordModel {
  final String word;
  final List<Phonetic> phonetics;
  final List<Meaning> meanings;

  WordModel({
    required this.word,
    required this.phonetics,
    required this.meanings,
  });

  // All synonyms across all meanings
  List<String> get allSynonyms => meanings
      .expand(
        (m) => [...m.synonyms, ...m.definitions.expand((d) => d.synonyms)],
      )
      .toSet()
      .toList();

  // All antonyms across all meanings
  List<String> get allAntonyms => meanings
      .expand(
        (m) => [...m.antonyms, ...m.definitions.expand((d) => d.antonyms)],
      )
      .toSet()
      .toList();

  // First audio URL found
  String? get audioUrl => phonetics
      .where((p) => p.audio != null && p.audio!.isNotEmpty)
      .map((p) => p.audio)
      .firstOrNull;

  // First phonetic text found
  String? get phoneticText => phonetics
      .where((p) => p.text != null && p.text!.isNotEmpty)
      .map((p) => p.text)
      .firstOrNull;

  factory WordModel.fromJson(Map<String, dynamic> json) => WordModel(
    word: json['word'] ?? '',
    phonetics: (json['phonetics'] as List<dynamic>? ?? [])
        .map((p) => Phonetic.fromJson(p))
        .toList(),
    meanings: (json['meanings'] as List<dynamic>? ?? [])
        .map((m) => Meaning.fromJson(m))
        .toList(),
  );
}
