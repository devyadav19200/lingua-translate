# 🌐 LinguaTranslate

A production-ready, cross-platform Flutter translation app with voice input/output, real-time translation, dark mode, and translation history.

---

## ✨ Features

| Feature | Details |
|---|---|
| 🌍 **Language Support** | 60+ languages with flag icons |
| 🎤 **Voice Input (STT)** | Real-time speech-to-text with sound-level animation |
| 🔊 **Text-to-Speech** | Speak translations in the target language |
| ♻️ **Swap Languages** | One-tap animated language swap |
| 📋 **Copy to Clipboard** | One-tap copy with snackbar confirmation |
| ⭐ **Favorites** | Bookmark translations for quick access |
| 📜 **History** | Full translation history with search & swipe-to-delete |
| 🌙 **Dark / Light Mode** | System-aware + manual toggle |
| ⚡ **Debounced Translation** | Auto-translates as you type (800ms debounce) |
| 🔄 **Free Translation API** | MyMemory API (no key required) + LibreTranslate fallback |

---

## 📁 Project Structure

```
lib/
├── main.dart                        # App entry point + MultiProvider
├── core/
│   ├── app_colors.dart              # Color palette (light + dark)
│   ├── app_theme.dart               # Material 3 themes
│   └── app_constants.dart           # Languages, API URLs, keys
├── models/
│   ├── language_model.dart          # Language data model
│   └── translation_model.dart       # Translation + history model
├── services/
│   ├── translation_service.dart     # MyMemory + LibreTranslate API
│   ├── speech_service.dart          # speech_to_text wrapper
│   ├── tts_service.dart             # flutter_tts wrapper
│   └── history_service.dart         # SharedPreferences storage
├── providers/
│   ├── theme_provider.dart          # Theme state
│   ├── translation_provider.dart    # Translation state + debounce
│   ├── history_provider.dart        # History state
│   └── speech_provider.dart         # STT + TTS combined state
├── screens/
│   ├── home_screen.dart             # Main translation screen
│   ├── history_screen.dart          # History + favorites screen
│   └── settings_screen.dart         # Settings (theme, speech rate)
└── widgets/
    ├── language_selector_bar.dart   # Source/target language bar
    ├── language_picker_modal.dart   # Bottom sheet language picker
    ├── source_input_card.dart       # Text input + listening indicator
    ├── translation_output_card.dart # Translated output + actions
    └── mic_button.dart              # Animated microphone button
```

---

## 🚀 Setup & Run

### Prerequisites

1. **Flutter SDK** ≥ 3.0.0 — [Install Flutter](https://docs.flutter.dev/get-started/install)
2. **Android Studio** or **Xcode** (for iOS)
3. A connected device or emulator

### Step 1 — Clone / Navigate

```bash
cd path/to/translater
```

### Step 2 — Add Fonts (Optional but Recommended)

Download **Poppins** from [Google Fonts](https://fonts.google.com/specimen/Poppins) and place the TTF files at:

```
assets/fonts/Poppins-Regular.ttf
assets/fonts/Poppins-Medium.ttf
assets/fonts/Poppins-SemiBold.ttf
assets/fonts/Poppins-Bold.ttf
```

Or remove the `fonts:` section from `pubspec.yaml` to use the default system font.

### Step 3 — Create Asset Directories

```bash
mkdir -p assets/images assets/animations assets/fonts
```

Or on Windows PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path assets\images, assets\animations, assets\fonts
```

### Step 4 — Install Dependencies

```bash
flutter pub get
```

### Step 5 — Run the App

```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d android
flutter run -d ios
flutter run -d chrome   # Web (limited speech support)
```

### Step 6 — Build Release APK (Android)

```bash
# Debug build
flutter build apk --debug

# Release build (requires signing config)
flutter build apk --release

# Split APKs by ABI (smaller size)
flutter build apk --split-per-abi --release
```

### Step 7 — Build Release IPA (iOS)

```bash
flutter build ios --release
# Then archive via Xcode
```

---

## 🔐 Native Permissions Setup

### Android (`android/app/src/main/AndroidManifest.xml`)

Already configured. Key permissions:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
```

### iOS (`ios/Runner/Info.plist`)

Already configured. Key entries:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>LinguaTranslate needs microphone access for voice translation.</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>LinguaTranslate uses Speech Recognition to convert speech to text.</string>
```

---

## 🌐 Translation API

The app uses **MyMemory API** (free, no API key required):
- **Free tier**: ~5,000 characters/day per IP
- **Higher quota**: Add your email to `TranslationService` (`de` parameter)
- **Fallback**: LibreTranslate (self-hostable, open-source)

### Using Google Translate API (Optional Upgrade)

1. Get an API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the **Cloud Translation API**
3. In `translation_service.dart`, add a method:

```dart
Future<TranslationResult> translateWithGoogle({
  required String text,
  required String sourceLang,
  required String targetLang,
  required String apiKey,
}) async {
  final uri = Uri.parse(AppConstants.googleTranslateUrl).replace(
    queryParameters: {
      'q': text,
      'source': sourceLang == 'auto' ? null : sourceLang,
      'target': targetLang,
      'key': apiKey,
      'format': 'text',
    }..removeWhere((_, v) => v == null),
  );
  final response = await http.post(uri);
  final data = jsonDecode(response.body);
  return TranslationResult(
    translatedText: data['data']['translations'][0]['translatedText'],
    detectedLanguage: data['data']['translations'][0]['detectedSourceLanguage'],
    success: true,
  );
}
```

---

## 🎨 Customization

### Adding a New Language

In `lib/core/app_constants.dart`, add to `supportedLanguages`:
```dart
{'code': 'xx', 'name': 'Language Name', 'flag': '🏳️'},
```

### Changing the Primary Color

In `lib/core/app_colors.dart`:
```dart
static const Color primary = Color(0xFF4F46E5); // Change this
```

### Adjusting Auto-Translate Debounce

In `lib/core/app_constants.dart`:
```dart
static const Duration translationDebounce = Duration(milliseconds: 800);
```

---

## 📦 Key Packages

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.2 | State management |
| `speech_to_text` | ^6.6.2 | Voice input |
| `flutter_tts` | ^4.0.2 | Text-to-speech |
| `http` | ^1.2.1 | Translation API calls |
| `shared_preferences` | ^2.2.3 | History persistence |
| `clipboard` | ^0.1.3 | Copy to clipboard |
| `uuid` | ^4.4.0 | Unique history IDs |
| `intl` | ^0.19.0 | Date formatting |
| `connectivity_plus` | ^6.0.3 | Network status |

---

## 🧪 Testing

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests (device required)
flutter test integration_test/
```

---

## 📱 Screenshots

| Home (Light) | Home (Dark) | History | Language Picker |
|---|---|---|---|
| Source input, language bar, mic button, translate | Full dark mode | Tabs, search, swipe-delete | Searchable modal with flags |

---

## 🏗️ Architecture

```
User Action
    │
    ▼
Widget (Consumer<Provider>)
    │
    ▼
Provider (ChangeNotifier)
    │
    ▼
Service (API / Local Storage / Device)
    │
    ▼
Model (TranslationModel / LanguageModel)
```

---

## 📄 License

MIT License — free to use, modify, and distribute.
