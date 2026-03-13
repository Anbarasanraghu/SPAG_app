import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey   = 'auth_token';
  static const _roleKey    = 'auth_role';
  static const _expiryKey  = 'token_expiry';

  static const _secureStorage = FlutterSecureStorage();

  // ─── Token ────────────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    debugPrint('[AuthService] Saving token: ${token.substring(0, 20)}...');

    // Save expiry — 24 hours from now
    final expiry = DateTime.now()
        .add(const Duration(hours: 24))
        .millisecondsSinceEpoch
        .toString();

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_expiryKey, expiry);
    } else {
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(key: _expiryKey, value: expiry);
    }

    debugPrint('[AuthService] Token saved successfully with expiry');
  }

  static Future<String?> getToken() async {
    // ── Check expiry first ──────────────────────────────────────────
    final expiryStr = kIsWeb
        ? (await SharedPreferences.getInstance()).getString(_expiryKey)
        : await _secureStorage.read(key: _expiryKey);

    if (expiryStr != null) {
      final expiry = int.tryParse(expiryStr) ?? 0;
      if (DateTime.now().millisecondsSinceEpoch > expiry) {
        debugPrint('[AuthService] Token expired — clearing session');
        await logout(); // clear everything
        return null;
      }
    }

    final token = kIsWeb
        ? (await SharedPreferences.getInstance()).getString(_tokenKey)
        : await _secureStorage.read(key: _tokenKey);

    debugPrint(
        '[AuthService] getToken() => ${token == null ? 'NULL' : '${token.substring(0, 20)}...'}');
    return token;
  }

  // ─── Role ─────────────────────────────────────────────────────────────────

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

  // ─── Logout ───────────────────────────────────────────────────────────────

  static Future<void> logout() async {
    debugPrint('[AuthService] Logging out — clearing all stored data');
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } else {
      await _secureStorage.deleteAll();
    }
    debugPrint('[AuthService] Logout complete');
  }
}