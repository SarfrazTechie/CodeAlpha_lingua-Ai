import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word_model.dart';

class DictionaryService {
  static const String _baseUrl =
      'https://api.dictionaryapi.dev/api/v2/entries/en';

  // Fetch word details — definitions, synonyms, antonyms, phonetics, audio
  Future<WordModel?> lookupWord(String word) async {
    if (word.trim().isEmpty) return null;

    try {
      final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(word.trim())}');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return WordModel.fromJson(data.first);
        }
        return null;
      } else if (response.statusCode == 404) {
        // Word not found in dictionary
        return null;
      } else {
        throw Exception('Dictionary lookup failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Dictionary error: $e');
    }
  }

  // Quick synonym fetch only
  Future<List<String>> getSynonyms(String word) async {
    final result = await lookupWord(word);
    return result?.allSynonyms ?? [];
  }

  // Quick antonym fetch only
  Future<List<String>> getAntonyms(String word) async {
    final result = await lookupWord(word);
    return result?.allAntonyms ?? [];
  }
}
