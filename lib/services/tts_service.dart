import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  late FlutterTts _flutterTts;
  bool _isSpeaking = false;
  double _currentSpeed = 0.5;
  String _currentLanguage = "en-US";

  Future<void> init() async {
    _flutterTts = FlutterTts();
    await _setVoiceSettings();

    _flutterTts.setCompletionHandler(() => _isSpeaking = false);
    _flutterTts.setErrorHandler((msg) => _isSpeaking = false);
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;

    bool available = await _flutterTts.isLanguageAvailable(languageCode);

    if (!available && languageCode == "ne-NP") {
      // ✅ Try Hindi first if Nepali not available
      if (await _flutterTts.isLanguageAvailable("hi-IN")) {
        _currentLanguage = "hi-IN";
      } else {
        _currentLanguage = "en-US";
      }
    }

    await _flutterTts.setLanguage(_currentLanguage);
    await _setVoiceSettings();
  }

  Future<void> _setVoiceSettings() async {
    // ✅ Adjust settings for Nepali/Hindi to sound clearer
    if (_currentLanguage == "ne-NP" || _currentLanguage == "hi-IN") {
      await _flutterTts.setSpeechRate(0.4); // slower for clarity
      await _flutterTts.setPitch(1.1);      // slightly higher pitch
    } else {
      await _flutterTts.setSpeechRate(_currentSpeed);
      await _flutterTts.setPitch(0.95);
    }

    await _flutterTts.setVolume(1.0);
    await _flutterTts.setLanguage(_currentLanguage);
  }

  Future<bool> speak(String text) async {
    if (_isSpeaking) await _flutterTts.stop();
    final cleanText = text
        .replaceAll(RegExp(r'[🚨✅📋🏥🎙⚠️🔄👋]'), '')
        .replaceAll(RegExp(r'\n+'), ' ')
        .trim();
    _isSpeaking = true;
    return await _flutterTts.speak(cleanText);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  bool get isSpeaking => _isSpeaking;
  String get currentLanguage => _currentLanguage;
}
