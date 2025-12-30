import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _kDark = 'settings_dark';
  static const _kSeed = 'settings_seed';

  bool _isDark = false;
  bool get isDark => _isDark;

  Color _seedColor = Colors.indigo;
  Color get seedColor => _seedColor;

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_kDark) ?? false;

    final seedInt = prefs.getInt(_kSeed);
    if (seedInt != null) _seedColor = Color(seedInt);

    _loaded = true;
    notifyListeners();
  }

  Future<void> toggleDark(bool value) async {
    _isDark = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDark, value);
  }

  Future<void> setSeed(Color color) async {
    _seedColor = color;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSeed, color.value);
  }
}
