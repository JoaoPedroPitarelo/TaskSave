import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  static const String _languageKey = 'app_language';
  static const String _isFirstLoginKey = 'is_first_login';

  bool _isDarkMode = false;
  bool _isFirstLogin = false;
  Locale _appLanguage = const Locale('pt');

  bool get isDark => _isDarkMode;
  bool get isFirstLogin => _isFirstLogin;
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

  Future<void> _loadFirstLogin() async {
    final preferences = await SharedPreferences.getInstance();
    _isFirstLogin = preferences.getBool(_isFirstLoginKey) ?? true;
  }

  Future<void> _loadPreferences() async {
    await _loadTheme();
    await _loadLanguage();
    await _loadFirstLogin();

    notifyListeners();
  }

  Future<void> toggleTheme({required bool isDark}) async {
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

  Future<void> setFirstLogin() async {
    final preferences = await SharedPreferences.getInstance();
    _isFirstLogin = false;
    await preferences.setBool(_isFirstLoginKey, _isFirstLogin);
    notifyListeners();
  }
}
