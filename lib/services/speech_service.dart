import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

enum SpeechStatus {
  uninitialized,
  ready,
  listening,
  processing,
  unavailable,
  error,
}

class SpeechService extends ChangeNotifier {
  SpeechService._();
  static final SpeechService instance = SpeechService._();

  final SpeechToText _speech = SpeechToText();

  SpeechStatus _status = SpeechStatus.uninitialized;
  String _recognizedText = '';
  String _lastError = '';
  double _soundLevel = 0.0;
  bool _isInitialized = false;
  List<LocaleName> _availableLocales = [];

  SpeechStatus get status => _status;
  String get recognizedText => _recognizedText;
  String get lastError => _lastError;
  double get soundLevel => _soundLevel;
  bool get isListening => _status == SpeechStatus.listening;
  bool get isInitialized => _isInitialized;
  List<LocaleName> get availableLocales => _availableLocales;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: kDebugMode,
      );

      if (_isInitialized) {
        _availableLocales = await _speech.locales();
        _status = SpeechStatus.ready;
      } else {
        _status = SpeechStatus.unavailable;
      }

      notifyListeners();
      return _isInitialized;
    } catch (e) {
      _status = SpeechStatus.error;
      _lastError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> startListening({
    required Function(String text) onResult,
    String? localeId,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    if (_speech.isListening) {
      await stopListening();
    }

    _recognizedText = '';
    _status = SpeechStatus.listening;
    notifyListeners();

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        _recognizedText = result.recognizedWords;
        onResult(_recognizedText);
        notifyListeners();
      },
      onSoundLevelChange: (double level) {
        _soundLevel = level;
        notifyListeners();
      },
      listenFor: const Duration(minutes: 2),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      localeId: localeId,
      cancelOnError: false,
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _status = SpeechStatus.ready;
    _soundLevel = 0.0;
    notifyListeners();
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
    _recognizedText = '';
    _status = SpeechStatus.ready;
    _soundLevel = 0.0;
    notifyListeners();
  }

  void _onError(SpeechRecognitionError error) {
    _lastError = error.errorMsg;
    if (error.errorMsg != 'error_speech_timeout') {
      _status = SpeechStatus.error;
    } else {
      _status = SpeechStatus.ready;
    }
    _soundLevel = 0.0;
    notifyListeners();
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      _status = SpeechStatus.ready;
      _soundLevel = 0.0;
      notifyListeners();
    }
  }

  /// Get the best locale ID for a given language code
  String? getLocaleId(String languageCode) {
    if (languageCode == 'auto') return null;
    try {
      final matching = _availableLocales.where(
        (locale) => locale.localeId.startsWith(languageCode),
      );
      return matching.isNotEmpty ? matching.first.localeId : null;
    } catch (_) {
      return null;
    }
  }

  void clearText() {
    _recognizedText = '';
    notifyListeners();
  }
}
