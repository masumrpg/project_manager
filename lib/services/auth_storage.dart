import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthStorage {
  AuthStorage(this._prefs);

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final SharedPreferences _prefs;

  static Future<AuthStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthStorage(prefs);
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  Future<String?> readToken() async {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  Future<void> saveUser(User user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> readUser() async {
    final value = _prefs.getString(_userKey);
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      return User.fromJson(jsonDecode(value) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUser() async {
    await _prefs.remove(_userKey);
  }

  Future<void> clearAll() async {
    await Future.wait([
      _prefs.remove(_tokenKey),
      _prefs.remove(_userKey),
    ]);
  }
}
