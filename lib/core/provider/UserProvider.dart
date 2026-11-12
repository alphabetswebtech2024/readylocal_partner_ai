import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/User.dart';
import '../network/token_storage.dart';

class UserProvider with ChangeNotifier {
  UserProvider();

  UserProvider.user({required User user}) {
    _user = user;
  }

  // Nullable — _user is not guaranteed to be set until loaded from prefs
  User? _user;

  /// Safe getter — returns null if not loaded yet
  User? get userOrNull => _user;

  /// Use this only when you are sure the user is loaded
  /// (i.e. after checking hasUser() or inside authenticated screens)
  User get user {
    if (_user == null) {
      throw StateError(
        'UserProvider._user is not initialized. '
            'Call loadUserFromPrefs() at app start or check userOrNull != null before accessing user.',
      );
    }
    return _user!;
  }

  set user(User user) {
    _user = user;
    notifyListeners();
  }

  void setUser(User user) {
    this.user = user;
  }

  /// Load user from SharedPreferences into memory.
  /// Call this once at app start inside your main() or root widget.
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      try {
        _user = User.fromJson(jsonDecode(userJson));
        notifyListeners();
      } catch (_) {
        // Corrupt data — clear it
        await prefs.remove('user');
      }
    }
  }

  Future<void> setAsCurrentUser(User user) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('user', jsonEncode(user));
    this.user = user;
  }

  Future<User> updateCurrentUser(User user) async {
    await setAsCurrentUser(user);
    notifyListeners();
    return user;
  }

  static Future<bool> hasUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('user') != null;
  }

  static Future<User?> getCurrentUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? user = preferences.getString('user');
    if (user != null) {
      try {
        return User.fromJson(jsonDecode(user));
      } catch (_) {
        // Corrupt data would otherwise leave the splash screen stuck.
        await preferences.remove('user');
      }
    }
    return null;
  }

  static Future<void> removeCurrentUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('user');
    preferences.remove('MembershipID');
    preferences.remove('MembershipPlan');
    preferences.remove('isPlanActive');
    preferences.remove('PlanEndDate');
    preferences.remove('PlanStartDate');
    TokenStorage.clear();
  }
}