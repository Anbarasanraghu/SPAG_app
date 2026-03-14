import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../features/auth/services/auth_service.dart';
import '../models/dashboard.dart';
import './api_config.dart';

class DashboardService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<CustomerDashboard> fetchDashboard() async {
    final token = await AuthService.getToken();

    debugPrint("[DashboardService] ========== API CALL START ==========");
    debugPrint("[DashboardService] TOKEN => ${token?.substring(0, 20)}...");

    if (token == null || token.isEmpty) {
      throw Exception("No token found");
    }

    final url = "$baseUrl/dashboard/customer";
    debugPrint("[DashboardService] URL => $url");

    final response = await http.get(
      Uri.parse(url), 
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    debugPrint("[DashboardService] HTTP STATUS => ${response.statusCode}");
    debugPrint("[DashboardService] RAW RESPONSE BODY:");
    debugPrint(response.body);
    debugPrint("[DashboardService] RESPONSE HEADERS: ${response.headers}");

    if (response.statusCode != 200) {
      debugPrint("[DashboardService] ERROR: Got status ${response.statusCode}");
      // Some backend builds return 404 when there is no installation yet.
      if (response.statusCode == 404) {
        final detail = () {
          try {
            final decoded = jsonDecode(response.body);
            return decoded['detail']?.toString() ?? response.body;
          } catch (_) {
            return response.body;
          }
        }();
        throw Exception("Installation not found: $detail");
      }
      throw Exception("Failed to load dashboard (Status: ${response.statusCode})");
    }

    final jsonData = jsonDecode(response.body);
    debugPrint("[DashboardService] DECODED JSON TYPE: ${jsonData.runtimeType}");
    
    // No longer throw for profile_completed false, just parse
    final dashboard = CustomerDashboard.fromJson(jsonData);
    
    debugPrint("[DashboardService] FINAL PARSED => customerId=${dashboard.customerId}, model='${dashboard.purifierModel}', date='${dashboard.installDate}', services=${dashboard.services.length}, profileCompleted=${dashboard.profileCompleted}");
    debugPrint("[DashboardService] ========== API CALL END ==========");
    
    return dashboard;
  }
}

