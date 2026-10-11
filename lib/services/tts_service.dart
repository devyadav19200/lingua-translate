import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

class TtsService extends ChangeNotifier {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _flutterTts = FlutterTts();
  TtsState _ttsState = TtsState.stopped;
  double _speechRate = 0.5;
  double _volume = 1.0;
  double _pitch = 1.0;
  String? _currentLanguage;

  TtsState get ttsState => _ttsState;
  bool get isPlaying => _ttsState == TtsState.playing;
  double get speechRate => _speechRate;
  double get volume => _volume;
  double get pitch => _pitch;

  Future<void> initialize() async {
    _flutterTts.setStartHandler(() {
      _ttsState = TtsState.playing;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _ttsState = TtsState.stopped;
      notifyListeners();
    });

    _flutterTts.setCancelHandler(() {
      _ttsState = TtsState.stopped;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      _ttsState = TtsState.stopped;
      notifyListeners();
    });

    if (!kIsWeb) {
      if (Platform.isAndroid) {
        await _flutterTts.setQueueMode(1);
      }
    }

    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(_volume);
    await _flutterTts.setPitch(_pitch);
  }

  Future<void> speak(String text, {String? languageCode}) async {
    if (text.trim().isEmpty) return;

    if (_ttsState == TtsState.playing) {
      await stop();
    }

    final lang = languageCode ?? _currentLanguage ?? 'en';
    await _setLanguage(lang);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _ttsState = TtsState.stopped;
    notifyListeners();
  }

  Future<void> pause() async {
    await _flutterTts.pause();
    _ttsState = TtsState.paused;
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.1, 1.0);
    await _flutterTts.setSpeechRate(_speechRate);
    notifyListeners();
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(_pitch);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _flutterTts.setVolume(_volume);
    notifyListeners();
  }

  Future<void> _setLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;

    // Map language codes to TTS-compatible locale strings
    final localeMap = {
      'en': 'en-US',
      'es': 'es-ES',
      'fr': 'fr-FR',
      'de': 'de-DE',
      'it': 'it-IT',
      'pt': 'pt-PT',
      'ru': 'ru-RU',
      'zh': 'zh-CN',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'ar': 'ar-SA',
      'hi': 'hi-IN',
      'tr': 'tr-TR',
      'nl': 'nl-NL',
      'pl': 'pl-PL',
      'sv': 'sv-SE',
      'da': 'da-DK',
      'fi': 'fi-FI',
      'no': 'no-NO',
      'vi': 'vi-VN',
      'th': 'th-TH',
      'id': 'id-ID',
      'ms': 'ms-MY',
      'cs': 'cs-CZ',
      'ro': 'ro-RO',
      'hu': 'hu-HU',
      'el': 'el-GR',
      'he': 'he-IL',
      'uk': 'uk-UA',
      'bg': 'bg-BG',
      'hr': 'hr-HR',
      'sk': 'sk-SK',
      'sl': 'sl-SI',
      'sr': 'sr-RS',
      'ca': 'ca-ES',
      'af': 'af-ZA',
      'sq': 'sq-AL',
      'bn': 'bn-BD',
      'ta': 'ta-IN',
      'te': 'te-IN',
      'ml': 'ml-IN',
      'kn': 'kn-IN',
      'mr': 'mr-IN',
      'gu': 'gu-IN',
      'ur': 'ur-PK',
      'fa': 'fa-IR',
      'sw': 'sw-KE',
      'tl': 'fil-PH',
    };

    final locale = localeMap[languageCode] ?? languageCode;
    await _flutterTts.setLanguage(locale);
    _currentLanguage = languageCode;
  }

  Future<List<String>> getAvailableLanguages() async {
    final languages = await _flutterTts.getLanguages;
    return (languages as List).cast<String>();
  }
}
