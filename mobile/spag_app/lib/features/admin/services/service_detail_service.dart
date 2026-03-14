import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../auth/services/auth_service.dart';
import '../models/service_detail.dart';
import '../../../core/api/api_config.dart';

class ServiceDetailService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<ServiceDetail> fetchServiceDetail(int serviceId) async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token missing");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/admin/services/$serviceId/details"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    // Debugging: print status and body to help diagnose parse issues
    debugPrint('ServiceDetail status: ${response.statusCode}');
    debugPrint('ServiceDetail body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to load service detail (${response.statusCode}): ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    try {
      return ServiceDetail.fromJson(decoded as Map<String, dynamic>);
    } catch (e, st) {
      debugPrint('Error parsing ServiceDetail: $e');
      debugPrint('$st');
      throw Exception('Failed to parse service detail: $e');
    }
  }
}

