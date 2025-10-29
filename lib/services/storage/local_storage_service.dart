import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();

  static final LocalStorageService instance = LocalStorageService._();

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async =>
      _preferences ??= await SharedPreferences.getInstance();

  Future<List<Map<String, dynamic>>> readCollection(String name) async {
    final prefs = await _prefs;
    final raw = prefs.getString(name);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      if (decoded is Map && decoded['items'] is List) {
        return (decoded['items'] as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
    } catch (_) {
      // If decoding fails we reset the value to avoid repeated crashes.
      await prefs.remove(name);
    }
    return [];
  }

  Future<void> writeCollection(
      String name, List<Map<String, dynamic>> data) async {
    final prefs = await _prefs;
    final payload = jsonEncode(data);
    await prefs.setString(name, payload);
  }

  Future<void> clear(String name) async {
    final prefs = await _prefs;
    await prefs.remove(name);
  }
}
