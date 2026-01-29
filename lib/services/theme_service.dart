import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'selected_theme';
  static const String _primaryColorKey = 'primary_color';
  static const String _secondaryColorKey = 'secondary_color';
  static const String _scaffoldBackgroundKey = 'scaffold_background_color';
  static const String _appBarColorKey = 'app_bar_color';

  static Future<void> saveTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeName);
  }

  static Future<String?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  static Future<void> savePrimaryColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, colorValue);
  }

  static Future<int?> getPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_primaryColorKey);
  }

  static Future<void> saveSecondaryColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_secondaryColorKey, colorValue);
  }

  static Future<int?> getSecondaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_secondaryColorKey);
  }

  static Future<void> saveScaffoldBackgroundColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_scaffoldBackgroundKey, colorValue);
  }

  static Future<int?> getScaffoldBackgroundColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_scaffoldBackgroundKey);
  }

  static Future<void> saveAppBarColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_appBarColorKey, colorValue);
  }

  static Future<int?> getAppBarColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_appBarColorKey);
  }
}