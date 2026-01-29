import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ko': '한국어',
    'ja': '日本語',
    'zh': '中文',
  };

  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  static Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  static String getLanguageName(String code) {
    return supportedLanguages[code] ?? 'English';
  }
}