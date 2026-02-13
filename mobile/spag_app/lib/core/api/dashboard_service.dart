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
      throw Exception("Failed to load dashboard (Status: ${response.statusCode})");
    }

    final jsonData = jsonDecode(response.body);
    debugPrint("[DashboardService] DECODED JSON TYPE: ${jsonData.runtimeType}");
    
    final dashboard = CustomerDashboard.fromJson(jsonData);
    
    debugPrint("[DashboardService] FINAL PARSED => customerId=${dashboard.customerId}, model='${dashboard.purifierModel}', date='${dashboard.installDate}', services=${dashboard.services.length}");
    debugPrint("[DashboardService] ========== API CALL END ==========");
    
    return dashboard;
  }
}
