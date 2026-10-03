import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Saves and loads app data on the device using `shared_preferences`.
///
/// All app data (exam, subjects, last answers, history) is turned into ONE
/// JSON string and saved under a single key. Simple and beginner friendly.
class StorageService {
  static const String _dataKey = 'exam_readiness_data_v1';
  static const String _darkModeKey = 'dark_mode';

  /// Returns the saved data, or null if nothing was saved yet
  /// (or if the saved text is damaged).
  Future<Map<String, dynamic>?> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dataKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dataKey, jsonEncode(data));
  }

  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }
}
