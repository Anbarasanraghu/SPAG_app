import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api/api_config.dart';

class AuthApi {

  static Future<void> sendOtp(String mobile) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile_number': mobile}),
    );
  }

  static Future<Map<String, dynamic>> verifyOtp(
      String mobile, String otp) async {

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile_number': mobile,
        'otp': otp,
      }),
    );

    return jsonDecode(response.body);
  }
}
