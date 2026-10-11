class AppConstants {
  AppConstants._();

  // Supported Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'auto', 'name': 'Auto Detect', 'flag': '🌐'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'es', 'name': 'Spanish', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'French', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'German', 'flag': '🇩🇪'},
    {'code': 'it', 'name': 'Italian', 'flag': '🇮🇹'},
    {'code': 'pt', 'name': 'Portuguese', 'flag': '🇵🇹'},
    {'code': 'nl', 'name': 'Dutch', 'flag': '🇳🇱'},
    {'code': 'pl', 'name': 'Polish', 'flag': '🇵🇱'},
    {'code': 'ru', 'name': 'Russian', 'flag': '🇷🇺'},
    {'code': 'zh', 'name': 'Chinese', 'flag': '🇨🇳'},
    {'code': 'ja', 'name': 'Japanese', 'flag': '🇯🇵'},
    {'code': 'ko', 'name': 'Korean', 'flag': '🇰🇷'},
    {'code': 'ar', 'name': 'Arabic', 'flag': '🇸🇦'},
    {'code': 'hi', 'name': 'Hindi', 'flag': '🇮🇳'},
    {'code': 'tr', 'name': 'Turkish', 'flag': '🇹🇷'},
    {'code': 'vi', 'name': 'Vietnamese', 'flag': '🇻🇳'},
    {'code': 'th', 'name': 'Thai', 'flag': '🇹🇭'},
    {'code': 'id', 'name': 'Indonesian', 'flag': '🇮🇩'},
    {'code': 'sv', 'name': 'Swedish', 'flag': '🇸🇪'},
    {'code': 'da', 'name': 'Danish', 'flag': '🇩🇰'},
    {'code': 'fi', 'name': 'Finnish', 'flag': '🇫🇮'},
    {'code': 'no', 'name': 'Norwegian', 'flag': '🇳🇴'},
    {'code': 'cs', 'name': 'Czech', 'flag': '🇨🇿'},
    {'code': 'ro', 'name': 'Romanian', 'flag': '🇷🇴'},
    {'code': 'hu', 'name': 'Hungarian', 'flag': '🇭🇺'},
    {'code': 'uk', 'name': 'Ukrainian', 'flag': '🇺🇦'},
    {'code': 'el', 'name': 'Greek', 'flag': '🇬🇷'},
    {'code': 'he', 'name': 'Hebrew', 'flag': '🇮🇱'},
    {'code': 'bn', 'name': 'Bengali', 'flag': '🇧🇩'},
    {'code': 'ms', 'name': 'Malay', 'flag': '🇲🇾'},
    {'code': 'fa', 'name': 'Persian', 'flag': '🇮🇷'},
    {'code': 'ur', 'name': 'Urdu', 'flag': '🇵🇰'},
    {'code': 'ta', 'name': 'Tamil', 'flag': '🇱🇰'},
    {'code': 'te', 'name': 'Telugu', 'flag': '🇮🇳'},
    {'code': 'mr', 'name': 'Marathi', 'flag': '🇮🇳'},
    {'code': 'ml', 'name': 'Malayalam', 'flag': '🇮🇳'},
    {'code': 'gu', 'name': 'Gujarati', 'flag': '🇮🇳'},
    {'code': 'kn', 'name': 'Kannada', 'flag': '🇮🇳'},
    {'code': 'af', 'name': 'Afrikaans', 'flag': '🇿🇦'},
    {'code': 'sq', 'name': 'Albanian', 'flag': '🇦🇱'},
    {'code': 'hy', 'name': 'Armenian', 'flag': '🇦🇲'},
    {'code': 'az', 'name': 'Azerbaijani', 'flag': '🇦🇿'},
    {'code': 'be', 'name': 'Belarusian', 'flag': '🇧🇾'},
    {'code': 'bs', 'name': 'Bosnian', 'flag': '🇧🇦'},
    {'code': 'bg', 'name': 'Bulgarian', 'flag': '🇧🇬'},
    {'code': 'ca', 'name': 'Catalan', 'flag': '🏴󠁥󠁳󠁣󠁴󠁿'},
    {'code': 'hr', 'name': 'Croatian', 'flag': '🇭🇷'},
    {'code': 'et', 'name': 'Estonian', 'flag': '🇪🇪'},
    {'code': 'ka', 'name': 'Georgian', 'flag': '🇬🇪'},
    {'code': 'lv', 'name': 'Latvian', 'flag': '🇱🇻'},
    {'code': 'lt', 'name': 'Lithuanian', 'flag': '🇱🇹'},
    {'code': 'mk', 'name': 'Macedonian', 'flag': '🇲🇰'},
    {'code': 'sr', 'name': 'Serbian', 'flag': '🇷🇸'},
    {'code': 'sk', 'name': 'Slovak', 'flag': '🇸🇰'},
    {'code': 'sl', 'name': 'Slovenian', 'flag': '🇸🇮'},
    {'code': 'sw', 'name': 'Swahili', 'flag': '🇰🇪'},
    {'code': 'tl', 'name': 'Filipino', 'flag': '🇵🇭'},
    {'code': 'is', 'name': 'Icelandic', 'flag': '🇮🇸'},
    {'code': 'ga', 'name': 'Irish', 'flag': '🇮🇪'},
    {'code': 'lb', 'name': 'Luxembourgish', 'flag': '🇱🇺'},
    {'code': 'mt', 'name': 'Maltese', 'flag': '🇲🇹'},
    {'code': 'cy', 'name': 'Welsh', 'flag': '🏴󠁧󠁢󠁷󠁬󠁳󠁿'},
  ];

  // Target languages (without 'auto')
  static List<Map<String, String>> get targetLanguages =>
      supportedLanguages.where((l) => l['code'] != 'auto').toList();

  // LibreTranslate endpoint (free, open source)
  static const String libreTranslateUrl = 'https://libretranslate.com/translate';
  static const String libreTranslateLangUrl = 'https://libretranslate.com/languages';

  // MyMemory API (free, no key needed for basic use)
  static const String myMemoryUrl = 'https://api.mymemory.translated.net/get';

  // Google Translate (unofficial)
  static const String googleTranslateUrl =
      'https://translation.googleapis.com/language/translate/v2';

  // History
  static const int maxHistoryItems = 100;
  static const String historyKey = 'translation_history';
  static const String favoritesKey = 'favorites';
  static const String themeKey = 'app_theme';
  static const String sourceLangKey = 'source_language';
  static const String targetLangKey = 'target_language';

  // Debounce
  static const Duration translationDebounce = Duration(milliseconds: 800);
  static const Duration animationDuration = Duration(milliseconds: 300);
}
