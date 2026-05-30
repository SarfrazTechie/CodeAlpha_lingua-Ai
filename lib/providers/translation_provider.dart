import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/translation_model.dart';
import '../services/translation_service.dart';

class TranslationProvider extends ChangeNotifier {
  static const String _historyKey = 'translation_history';
  static const String _srcLangKey = 'default_source_lang';
  static const String _tgtLangKey = 'default_target_lang';

  final TranslationService _service = TranslationService();

  String _sourceText = '';
  String _translatedText = '';
  String _sourceLang = 'en';
  String _targetLang = 'ur';

  bool _isTranslating = false;
  String? _error;

  List<TranslationModel> _history = [];

  Timer? _debounce;

  // Getters
  String get sourceText => _sourceText;
  String get translatedText => _translatedText;
  String get sourceLang => _sourceLang;
  String get targetLang => _targetLang;
  bool get isTranslating => _isTranslating;
  String? get error => _error;
  List<TranslationModel> get history => _history;
  List<TranslationModel> get favourites =>
      _history.where((t) => t.isFavourite).toList();

  String get sourceLangName =>
      TranslationService.supportedLanguages[_sourceLang] ?? _sourceLang;
  String get targetLangName =>
      TranslationService.supportedLanguages[_targetLang] ?? _targetLang;

  TranslationProvider() {
    _loadPreferences();
    _loadHistory();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _sourceLang = prefs.getString(_srcLangKey) ?? 'en';
    _targetLang = prefs.getString(_tgtLangKey) ?? 'ur';
    notifyListeners();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    _history = raw
        .map((e) => TranslationModel.fromJson(jsonDecode(e)))
        .toList()
        .reversed
        .toList();
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _history.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_historyKey, raw);
  }

  // Called on every keystroke — debounced 600ms
  void onSourceTextChanged(String text) {
    _sourceText = text;
    _error = null;
    notifyListeners();

    _debounce?.cancel();
    if (text.trim().isEmpty) {
      _translatedText = '';
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 600), () {
      translate();
    });
  }

  Future<void> translate() async {
    if (_sourceText.trim().isEmpty) return;

    _isTranslating = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.translate(
        text: _sourceText,
        sourceLang: _sourceLang,
        targetLang: _targetLang,
      );
      _translatedText = result;

      // Save to history
      final entry = TranslationModel(
        sourceText: _sourceText,
        translatedText: _translatedText,
        sourceLang: _sourceLang,
        targetLang: _targetLang,
        timestamp: DateTime.now(),
      );
      _history.insert(0, entry);
      if (_history.length > 200) _history = _history.sublist(0, 200);
      await _saveHistory();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  void swapLanguages() {
    final tempLang = _sourceLang;
    _sourceLang = _targetLang;
    _targetLang = tempLang;

    final tempText = _sourceText;
    _sourceText = _translatedText;
    _translatedText = tempText;

    notifyListeners();
    _saveLanguagePrefs();

    if (_sourceText.isNotEmpty) translate();
  }

  Future<void> setSourceLang(String lang) async {
    _sourceLang = lang;
    notifyListeners();
    await _saveLanguagePrefs();
    if (_sourceText.isNotEmpty) translate();
  }

  Future<void> setTargetLang(String lang) async {
    _targetLang = lang;
    notifyListeners();
    await _saveLanguagePrefs();
    if (_sourceText.isNotEmpty) translate();
  }

  Future<void> _saveLanguagePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_srcLangKey, _sourceLang);
    await prefs.setString(_tgtLangKey, _targetLang);
  }

  void toggleFavourite(int index) {
    _history[index].isFavourite = !_history[index].isFavourite;
    notifyListeners();
    _saveHistory();
  }

  void deleteHistoryItem(int index) {
    _history.removeAt(index);
    notifyListeners();
    _saveHistory();
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  void clearInput() {
    _sourceText = '';
    _translatedText = '';
    _error = null;
    _debounce?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
