import 'package:flutter/foundation.dart';
import '../api/auth_api.dart';

/// Simple response model returned after OTP verification
class AuthResponse {
  final String token;
  final String role;
  final bool profileExists;

  AuthResponse({
    required this.token,
    required this.role,
    required this.profileExists,
  });
}

/// AuthController
/// - Talks ONLY to backend
/// - DOES NOT store token
/// - Storage is handled by AuthService (UI layer)
class AuthController {
  /// Send OTP to given mobile number
  /// Login with phone + password
  /// Returns token, role and profile_exists flag
  Future<AuthResponse> login(String phone, String password) async {
    final data = await AuthApi.login(phone, password);

    if (data['token'] == null || data['role'] == null || data['profile_exists'] == null) {
      debugPrint('AuthController.login: invalid response => $data');
      throw Exception('Invalid auth response from server');
    }

    return AuthResponse(
      token: data['token'],
      role: data['role'],
      profileExists: data['profile_exists'] is bool ? data['profile_exists'] : (data['profile_exists'].toString().toLowerCase() == 'true'),
    );
  }

  /// Register new user (name, phone, password)
  /// Returns backend response map
  Future<Map<String, dynamic>> register(String name, String phone, String password) async {
    final data = await AuthApi.register(name, phone, password);
    return data;
  }

  /// Forgot Password: Send OTP to phone
  Future<void> forgotPassword(String phone) async {
    await AuthApi.forgotPassword(phone);
  }

  /// Verify Reset OTP
  Future<void> verifyResetOtp(String phone, String otp) async {
    await AuthApi.verifyResetOtp(phone, otp);
  }

  /// Reset Password
  Future<void> resetPassword(String phone, String newPassword) async {
    await AuthApi.resetPassword(phone, newPassword);
  }
}
