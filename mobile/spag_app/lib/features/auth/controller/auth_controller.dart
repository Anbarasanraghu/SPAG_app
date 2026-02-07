import 'package:flutter/foundation.dart';
import '../api/auth_api.dart';

/// Simple response model returned after OTP verification
class AuthResponse {
  final String token;
  final String role;

  AuthResponse({
    required this.token,
    required this.role,
  });
}

/// AuthController
/// - Talks ONLY to backend
/// - DOES NOT store token
/// - Storage is handled by AuthService (UI layer)
class AuthController {
  /// Send OTP to given mobile number
  Future<void> sendOtp(String mobile) async {
    await AuthApi.sendOtp(mobile);
  }

  /// Verify OTP and return auth data
  /// ❌ Does NOT save token
  /// ✅ Only returns token + role
  Future<AuthResponse> verifyOtp(String mobile, String otp) async {
    final data = await AuthApi.verifyOtp(mobile, otp);

    if (data['token'] == null || data['role'] == null) {
      debugPrint('AuthController.verifyOtp: invalid response => $data');
      throw Exception('Token or role missing from response');
    }

    return AuthResponse(
      token: data['token'],
      role: data['role'],
    );
  }
}
