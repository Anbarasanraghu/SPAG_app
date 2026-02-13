import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../auth/services/auth_service.dart';
import '../../../core/api/api_config.dart';

class CustomerProfileService {
  static const baseUrl = ApiConfig.baseUrl;

  static Future<bool> profileExists() async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        debugPrint('CustomerProfileService: No token found');
        return false;
      }
      
      debugPrint('CustomerProfileService: Checking profile with token=${token.substring(0, 20)}...');
      
      final res = await http.get(
        Uri.parse("$baseUrl/customer/profile/exists"),
        headers: {"Authorization": "Bearer $token"},
      );
      
      debugPrint('CustomerProfileService: Status code=${res.statusCode}');
      debugPrint('CustomerProfileService: Response body=${res.body}');
      
      if (res.statusCode != 200) {
        debugPrint('CustomerProfileService: API returned ${res.statusCode}, treating as no profile');
        return false;
      }
      
      final data = jsonDecode(res.body);
      final exists = data["exists"] == true;
      debugPrint('CustomerProfileService: Profile exists=$exists');
      return exists;
    } catch (e, st) {
      debugPrint('CustomerProfileService.profileExists ERROR: $e');
      debugPrint('$st');
      return false;
    }
  }

  static Future<void> createProfile(Map<String, dynamic> payload) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse("$baseUrl/customer/profile"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to save customer profile");
    }
  }
}
