import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api/api_config.dart';

class AuthApi {
  /// Login with phone + password
  /// Returns backend decoded JSON containing token, role, profile_exists
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  /// Register a new user
  /// Returns backend response (may include token/profile flags)
  static Future<Map<String, dynamic>> register(String name, String phone, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'phone': phone, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  /// Forgot Password: Send OTP to phone
  static Future<Map<String, dynamic>> forgotPassword(String phone) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    return jsonDecode(response.body);
  }

  /// Verify Reset OTP
  static Future<Map<String, dynamic>> verifyResetOtp(String phone, String otp) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/verify-reset-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );

    return jsonDecode(response.body);
  }

  /// Reset Password
  static Future<Map<String, dynamic>> resetPassword(String phone, String newPassword) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'new_password': newPassword}),
    );

    return jsonDecode(response.body);
  }
}

