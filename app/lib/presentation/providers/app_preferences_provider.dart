import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  static const String _languageKey = 'app_language';

  bool _isDarkMode = false;
  Locale _appLanguage = const Locale('pt');

  bool get isDark => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  Locale get appLanguage => _appLanguage;

  AppPreferencesProvider() {
    _loadPreferences();
  }

  Future<void> _loadTheme() async {
    final preferences = await SharedPreferences.getInstance();
    _isDarkMode = preferences.getBool(_themeKey) ?? false;
  }

  Future<void> _loadLanguage() async {
    final preferences = await SharedPreferences.getInstance();

    final String? languageString = preferences.getString(_languageKey);
    if (languageString != null) {
      _appLanguage = Locale(languageString);
    }
  }

  Future<void> _loadPreferences() async {
    await _loadTheme();
    await _loadLanguage();
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    if (_isDarkMode == isDark) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();

    _isDarkMode = isDark;
    await preferences.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setAppLanguage(Locale newLanguage) async {
    if (_appLanguage == newLanguage) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();

    _appLanguage = newLanguage;
    await preferences.setString(_languageKey, _appLanguage.languageCode);
    notifyListeners();
  }
}
