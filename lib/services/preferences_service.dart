import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme Mode
  ThemeMode get themeMode {
    final themeIndex = _prefs.getInt('themeMode') ?? 0;
    return ThemeMode.values[themeIndex];
  }

  set themeMode(ThemeMode mode) {
    _prefs.setInt('themeMode', mode.index);
  }

  // Primary Color
  Color get primaryColor {
    final colorValue = _prefs.getInt('primaryColor') ?? Colors.blue.value;
    return Color(colorValue);
  }

  set primaryColor(Color color) {
    _prefs.setInt('primaryColor', color.value);
  }

  // Secondary Color
  // Color get secondaryColor {
  //   final colorValue = _prefs.getInt('secondaryColor') ?? Colors.green.value;
  //   return Color(colorValue);
  // }

  // set secondaryColor(Color color) {
  //   _prefs.setInt('secondaryColor', color.value);
  // }

  // Language
  String get language {
    return _prefs.getString('language') ?? 'ar';
  }

  set language(String lang) {
    _prefs.setString('language', lang);
  }

  // Notifications Enabled
  bool get notificationsEnabled {
    return _prefs.getBool('notifications') ?? true;
  }

  set notificationsEnabled(bool enabled) {
    _prefs.setBool('notifications', enabled);
  }

  // Clear all preferences
  Future<void> clearPreferences() async {
    await _prefs.clear();
  }
}
