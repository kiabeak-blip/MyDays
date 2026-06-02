import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  final String id;
  final String name;
  final int colorValue;
  final String? emoji; // for member-inspired themes

  const AppTheme({
    required this.id,
    required this.name,
    required this.colorValue,
    this.emoji,
  });

  Color get color => Color(colorValue);
}

// ── Built-in theme palette ────────────────────────────────────────────────

const List<AppTheme> builtinThemes = [
  AppTheme(id: 'indigo',  name: 'Indigo',   colorValue: 0xFF5C6BC0),
  AppTheme(id: 'ocean',   name: 'Ocean',    colorValue: 0xFF0288D1),
  AppTheme(id: 'teal',    name: 'Teal',     colorValue: 0xFF00796B),
  AppTheme(id: 'forest',  name: 'Forest',   colorValue: 0xFF388E3C),
  AppTheme(id: 'amber',   name: 'Amber',    colorValue: 0xFFF57C00),
  AppTheme(id: 'sunset',  name: 'Sunset',   colorValue: 0xFFE64A19),
  AppTheme(id: 'rose',    name: 'Rose',     colorValue: 0xFFE91E63),
  AppTheme(id: 'purple',  name: 'Purple',   colorValue: 0xFF7B1FA2),
];

class ThemeProvider extends ChangeNotifier {
  static const _keyColor    = 'theme_color';
  static const _keyDark     = 'theme_dark';

  int _colorValue  = 0xFF5C6BC0; // default: Indigo
  bool _isDark     = false;

  int  get colorValue => _colorValue;
  bool get isDark     => _isDark;
  Color get seedColor => Color(_colorValue);
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _colorValue = prefs.getInt(_keyColor)   ?? 0xFF5C6BC0;
    _isDark     = prefs.getBool(_keyDark)   ?? false;
    notifyListeners();
  }

  Future<void> setColor(int colorValue) async {
    _colorValue = colorValue;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyColor, colorValue);
  }

  Future<void> setDark(bool isDark) async {
    _isDark = isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDark, isDark);
  }

  ThemeData buildTheme(Brightness brightness) => ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: brightness,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 1,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
}
