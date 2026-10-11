import 'package:flutter/foundation.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';

class SpeechProvider extends ChangeNotifier {
  final SpeechService _speechService = SpeechService.instance;
  final TtsService _ttsService = TtsService.instance;

  bool _isSpeechInitialized = false;
  bool _isTtsInitialized = false;

  bool get isListening => _speechService.isListening;
  bool get isSpeechInitialized => _isSpeechInitialized;
  bool get isTtsPlaying => _ttsService.isPlaying;
  double get soundLevel => _speechService.soundLevel;
  SpeechStatus get speechStatus => _speechService.status;
  String get lastSpeechError => _speechService.lastError;

  SpeechProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _ttsService.initialize();
    _isTtsInitialized = true;

    _isSpeechInitialized = await _speechService.initialize();
    notifyListeners();
  }

  Future<bool> startListening({
    required Function(String text) onResult,
    String? languageCode,
  }) async {
    if (!_isSpeechInitialized) {
      _isSpeechInitialized = await _speechService.initialize();
    }

    if (!_isSpeechInitialized) return false;

    final localeId = _speechService.getLocaleId(languageCode ?? 'en');

    await _speechService.startListening(
      onResult: (text) {
        onResult(text);
        notifyListeners();
      },
      localeId: localeId,
    );

    notifyListeners();
    return true;
  }

  Future<void> stopListening() async {
    await _speechService.stopListening();
    notifyListeners();
  }

  Future<void> cancelListening() async {
    await _speechService.cancelListening();
    notifyListeners();
  }

  Future<void> speak(String text, {String? languageCode}) async {
    await _ttsService.speak(text, languageCode: languageCode);
    notifyListeners();
  }

  Future<void> stopSpeaking() async {
    await _ttsService.stop();
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    await _ttsService.setSpeechRate(rate);
    notifyListeners();
  }

  double get speechRate => _ttsService.speechRate;
}
