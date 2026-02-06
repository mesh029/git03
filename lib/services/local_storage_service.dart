import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight local persistence for prototype-perfect state.
/// (No backend required; survives app restarts.)
class LocalStorageService {
  static const _kAuthUserEmail = 'auth.user.email';
  static const _kListingsJson = 'listings.json';
  static const _kOrdersJson = 'orders.json';
  static const _kMessagesJson = 'messages.json';

  static Future<void> setCurrentUserEmail(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null) {
      await prefs.remove(_kAuthUserEmail);
    } else {
      await prefs.setString(_kAuthUserEmail, email);
    }
  }

  static Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAuthUserEmail);
  }

  static Future<void> setListingsJson(List<Map<String, dynamic>> listings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kListingsJson, jsonEncode(listings));
  }

  static Future<List<Map<String, dynamic>>?> getListingsJson() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kListingsJson);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! List) return null;
    return decoded.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  static Future<void> setOrdersJson(List<Map<String, dynamic>> orders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kOrdersJson, jsonEncode(orders));
  }

  static Future<List<Map<String, dynamic>>?> getOrdersJson() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kOrdersJson);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! List) return null;
    return decoded.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  static Future<void> setMessagesJson(List<Map<String, dynamic>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMessagesJson, jsonEncode(messages));
  }

  static Future<List<Map<String, dynamic>>?> getMessagesJson() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kMessagesJson);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! List) return null;
    return decoded.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }
}

