import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'auth_role';

  static const _secureStorage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    debugPrint('[AuthService] Saving token: ${token.substring(0, 20)}...');
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } else {
      await _secureStorage.write(key: _tokenKey, value: token);
    }
    debugPrint('[AuthService] Token saved successfully');
  }

  static Future<String?> getToken() async {
    final token = kIsWeb
        ? (await SharedPreferences.getInstance()).getString(_tokenKey)
        : await _secureStorage.read(key: _tokenKey);
    debugPrint('[AuthService] getToken() => ${token == null ? 'NULL' : token.substring(0, 20)}...');
    return token;
  }

  static Future<void> saveRole(String role) async {
    debugPrint('[AuthService] Saving role: $role');
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_roleKey, role);
    } else {
      await _secureStorage.write(key: _roleKey, value: role);
    }
    debugPrint('[AuthService] Role saved successfully');
  }

  static Future<String?> getRole() async {
    final role = kIsWeb
        ? (await SharedPreferences.getInstance()).getString(_roleKey)
        : await _secureStorage.read(key: _roleKey);
    debugPrint('[AuthService] getRole() => $role');
    return role;
  }

  static Future<void> logout() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } else {
      await _secureStorage.deleteAll();
    }
  }
}
