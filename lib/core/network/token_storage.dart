import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _key = 'auth_token';
  static String? _cached; // in-memory copy so we don't hit disk on every call

  /// Call once in main() before runApp()
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _cached = prefs.getString(_key);
  }

  static String? get token => _cached;

  static Future<void> save(String token) async {
    _cached = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  static Future<void> saveToken(String token) => save(token);

  static Future<void> clear() async {
    _cached = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}