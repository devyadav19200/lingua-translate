import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/language_model.dart';
import '../services/translation_service.dart';
import '../core/app_constants.dart';

enum TranslationState { idle, translating, success, error }

class TranslationProvider extends ChangeNotifier {
  // Languages
  LanguageModel _sourceLang = LanguageModel.fromMap(
      AppConstants.supportedLanguages.first); // Auto
  LanguageModel _targetLang = LanguageModel.fromMap(
      AppConstants.supportedLanguages[1]); // English

  // Text
  String _sourceText = '';
  String _translatedText = '';
  String? _detectedLang;

  // State
  TranslationState _state = TranslationState.idle;
  String _errorMessage = '';

  // Debounce
  Timer? _debounceTimer;

  // Available languages
  final List<LanguageModel> _sourceLanguages = AppConstants.supportedLanguages
      .map((l) => LanguageModel.fromMap(l))
      .toList();
  final List<LanguageModel> _targetLanguages = AppConstants.targetLanguages
      .map((l) => LanguageModel.fromMap(l))
      .toList();

  // Getters
  LanguageModel get sourceLang => _sourceLang;
  LanguageModel get targetLang => _targetLang;
  String get sourceText => _sourceText;
  String get translatedText => _translatedText;
  String? get detectedLang => _detectedLang;
  TranslationState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isTranslating => _state == TranslationState.translating;
  List<LanguageModel> get sourceLanguages => _sourceLanguages;
  List<LanguageModel> get targetLanguages => _targetLanguages;

  TranslationProvider() {
    _loadSavedLanguages();
  }

  Future<void> _loadSavedLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    final srcCode = prefs.getString(AppConstants.sourceLangKey);
    final tgtCode = prefs.getString(AppConstants.targetLangKey);

    if (srcCode != null) {
      final found = _sourceLanguages.where((l) => l.code == srcCode);
      if (found.isNotEmpty) _sourceLang = found.first;
    }
    if (tgtCode != null) {
      final found = _targetLanguages.where((l) => l.code == tgtCode);
      if (found.isNotEmpty) _targetLang = found.first;
    }
    notifyListeners();
  }

  Future<void> setSourceLanguage(LanguageModel lang) async {
    _sourceLang = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.sourceLangKey, lang.code);
    if (_sourceText.isNotEmpty) {
      _triggerTranslation();
    }
  }

  Future<void> setTargetLanguage(LanguageModel lang) async {
    _targetLang = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.targetLangKey, lang.code);
    if (_sourceText.isNotEmpty) {
      _triggerTranslation();
    }
  }

  void swapLanguages() {
    // Can't swap if source is auto-detect
    if (_sourceLang.isAutoDetect) {
      // Set source to target, target to English
      final newSource = _targetLang;
      _targetLang = _targetLanguages.firstWhere(
        (l) => l.code == 'en',
        orElse: () => _targetLanguages.first,
      );
      _sourceLang = newSource;
    } else {
      final temp = _sourceLang;
      final newSource = _targetLanguages.firstWhere(
        (l) => l.code == _targetLang.code,
        orElse: () => _targetLanguages.first,
      );
      _sourceLang = newSource;
      _targetLang = _targetLanguages.firstWhere(
        (l) => l.code == temp.code,
        orElse: () => _targetLanguages.first,
      );
    }

    // Also swap texts
    final tempText = _sourceText;
    _sourceText = _translatedText;
    _translatedText = tempText;

    notifyListeners();

    if (_sourceText.isNotEmpty) {
      _triggerTranslation();
    }
  }

  void updateSourceText(String text) {
    _sourceText = text;
    if (text.isEmpty) {
      _translatedText = '';
      _state = TranslationState.idle;
      notifyListeners();
      _debounceTimer?.cancel();
      return;
    }
    _triggerTranslation();
    notifyListeners();
  }

  void setSourceTextFromSpeech(String text) {
    _sourceText = text;
    notifyListeners();
  }

  void _triggerTranslation() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(AppConstants.translationDebounce, () {
      translate();
    });
  }

  Future<void> translate() async {
    if (_sourceText.trim().isEmpty) return;

    _state = TranslationState.translating;
    _errorMessage = '';
    notifyListeners();

    final result = await TranslationService.instance.translate(
      text: _sourceText,
      sourceLang: _sourceLang.code,
      targetLang: _targetLang.code,
    );

    if (result.success) {
      _translatedText = result.translatedText;
      _detectedLang = result.detectedLanguage;
      _state = TranslationState.success;
    } else {
      _errorMessage = result.errorMessage ?? 'Translation failed';
      _state = TranslationState.error;
    }

    notifyListeners();
  }

  void clearAll() {
    _sourceText = '';
    _translatedText = '';
    _detectedLang = null;
    _state = TranslationState.idle;
    _errorMessage = '';
    _debounceTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
