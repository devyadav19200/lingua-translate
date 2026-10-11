import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_constants.dart';

class TranslationResult {
  final String translatedText;
  final String? detectedLanguage;
  final bool success;
  final String? errorMessage;

  const TranslationResult({
    required this.translatedText,
    this.detectedLanguage,
    required this.success,
    this.errorMessage,
  });

  factory TranslationResult.error(String message) {
    return TranslationResult(
      translatedText: '',
      success: false,
      errorMessage: message,
    );
  }
}

class TranslationService {
  TranslationService._();
  static final TranslationService instance = TranslationService._();

  /// Primary: MyMemory API (free, no key required up to 5000 chars/day per IP)
  Future<TranslationResult> translateWithMyMemory({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    if (text.trim().isEmpty) {
      return const TranslationResult(translatedText: '', success: true);
    }

    final effectiveSource = sourceLang == 'auto' ? 'en' : sourceLang;
    final langPair = '$effectiveSource|$targetLang';

    try {
      final uri = Uri.parse(AppConstants.myMemoryUrl).replace(
        queryParameters: {
          'q': text,
          'langpair': langPair,
          'de': 'app@linguatranslate.com', // Optional contact email for higher quota
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['responseStatus'];

        if (status == 200) {
          final translated = data['responseData']['translatedText'] as String;
          // Decode HTML entities
          final decodedText = _decodeHtmlEntities(translated);
          return TranslationResult(
            translatedText: decodedText,
            success: true,
          );
        } else {
          return TranslationResult.error(
              'Translation failed: ${data['responseDetails']}');
        }
      } else {
        return TranslationResult.error(
            'Server error: ${response.statusCode}');
      }
    } on Exception catch (e) {
      return TranslationResult.error('Network error: ${e.toString()}');
    }
  }

  /// Fallback: LibreTranslate (open source, free tier)
  Future<TranslationResult> translateWithLibreTranslate({
    required String text,
    required String sourceLang,
    required String targetLang,
    String? apiKey,
  }) async {
    if (text.trim().isEmpty) {
      return const TranslationResult(translatedText: '', success: true);
    }

    final effectiveSource = sourceLang == 'auto' ? 'en' : sourceLang;

    try {
      final response = await http.post(
        Uri.parse(AppConstants.libreTranslateUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': effectiveSource,
          'target': targetLang,
          'format': 'text',
          if (apiKey != null) 'api_key': apiKey,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TranslationResult(
          translatedText: data['translatedText'] as String,
          detectedLanguage: data['detectedLanguage']?['language'] as String?,
          success: true,
        );
      } else {
        final data = jsonDecode(response.body);
        return TranslationResult.error(
            data['error'] ?? 'Translation failed');
      }
    } on Exception catch (e) {
      return TranslationResult.error('Network error: ${e.toString()}');
    }
  }

  /// Main translate method — tries MyMemory first, falls back to LibreTranslate
  Future<TranslationResult> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    // Skip if same language
    if (sourceLang == targetLang && sourceLang != 'auto') {
      return TranslationResult(translatedText: text, success: true);
    }

    // Try MyMemory first
    final result = await translateWithMyMemory(
      text: text,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );

    if (result.success) return result;

    // Fallback to LibreTranslate
    return translateWithLibreTranslate(
      text: text,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
  }

  /// Detect language of a given text
  Future<String?> detectLanguage(String text) async {
    if (text.trim().isEmpty) return null;
    try {
      final uri = Uri.parse(AppConstants.myMemoryUrl).replace(
        queryParameters: {
          'q': text,
          'langpair': 'en|es', // dummy pair — detection side effect
        },
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['responseData']?['detectedLanguage'] as String?;
      }
    } catch (_) {}
    return null;
  }

  String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&nbsp;', ' ');
  }
}
