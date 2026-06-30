import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  String get label => switch (_themeMode) {
    ThemeMode.light  => 'Claro',
    ThemeMode.system => 'Según el teléfono',
    _                => 'Oscuro',
  };

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = _parse(prefs.getString(_key) ?? 'dark');
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _serialize(mode));
  }

  ThemeMode _parse(String s) => switch (s) {
    'light'  => ThemeMode.light,
    'system' => ThemeMode.system,
    _        => ThemeMode.dark,
  };

  String _serialize(ThemeMode m) => switch (m) {
    ThemeMode.light  => 'light',
    ThemeMode.system => 'system',
    _                => 'dark',
  };
}
