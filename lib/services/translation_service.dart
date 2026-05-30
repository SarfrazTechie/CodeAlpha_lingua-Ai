import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  // Google Translate unofficial API (free, no key needed)
  static const String _baseUrl = 'https://translate.googleapis.com/translate_a/single';

  Future<String> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    if (text.trim().isEmpty) return '';
    try {
      final uri = Uri.parse(
        '$_baseUrl?client=gtx&sl=$sourceLang&tl=$targetLang&dt=t&q=${Uri.encodeComponent(text)}',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final buffer = StringBuffer();
        for (final item in data[0]) {
          if (item[0] != null) buffer.write(item[0]);
        }
        return buffer.toString();
      } else {
        throw Exception('Translation failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Translation error: $e');
    }
  }

  Future<String> detectLanguage(String text) async {
    if (text.trim().isEmpty) return 'en';
    try {
      final uri = Uri.parse(
        '$_baseUrl?client=gtx&sl=auto&tl=en&dt=t&q=${Uri.encodeComponent(text)}',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data[2] ?? 'en';
      }
    } catch (_) {}
    return 'en';
  }

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ur': 'Urdu',
    'ar': 'Arabic',
    'fr': 'French',
    'de': 'German',
    'es': 'Spanish',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
    'hi': 'Hindi',
    'tr': 'Turkish',
    'nl': 'Dutch',
    'pl': 'Polish',
    'sv': 'Swedish',
    'da': 'Danish',
    'fi': 'Finnish',
    'no': 'Norwegian',
    'cs': 'Czech',
    'ro': 'Romanian',
    'hu': 'Hungarian',
    'el': 'Greek',
    'he': 'Hebrew',
    'th': 'Thai',
    'vi': 'Vietnamese',
    'id': 'Indonesian',
    'ms': 'Malay',
    'fa': 'Persian',
    'bn': 'Bengali',
    'uk': 'Ukrainian',
    'bg': 'Bulgarian',
    'hr': 'Croatian',
    'sk': 'Slovak',
    'sl': 'Slovenian',
    'lt': 'Lithuanian',
    'lv': 'Latvian',
    'et': 'Estonian',
    'ca': 'Catalan',
    'sr': 'Serbian',
    'af': 'Afrikaans',
    'sq': 'Albanian',
    'hy': 'Armenian',
    'az': 'Azerbaijani',
    'be': 'Belarusian',
    'bs': 'Bosnian',
    'mk': 'Macedonian',
    'sw': 'Swahili',
    'tl': 'Filipino',
    'gl': 'Galician',
    'ka': 'Georgian',
    'is': 'Icelandic',
    'ga': 'Irish',
    'mt': 'Maltese',
    'ne': 'Nepali',
    'pa': 'Punjabi',
    'si': 'Sinhala',
    'ta': 'Tamil',
    'te': 'Telugu',
    'uz': 'Uzbek',
  };
}
