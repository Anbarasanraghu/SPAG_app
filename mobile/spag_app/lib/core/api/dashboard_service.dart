import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../features/auth/services/auth_service.dart';
import '../models/dashboard.dart';

class DashboardService {
  static const String baseUrl = "http://localhost:8000";

  static Future<CustomerDashboard> fetchDashboard() async {
    final token = await AuthService.getToken();

    debugPrint("DASHBOARD SERVICE TOKEN => $token");

    if (token == null || token.isEmpty) {
      throw Exception("No token found");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/dashboard/customer"), // ✅ FIXED
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    debugPrint("DASHBOARD STATUS => ${response.statusCode}");
    debugPrint("DASHBOARD BODY => ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load dashboard");
    }

    return CustomerDashboard.fromJson(
      jsonDecode(response.body),
    );
  }
}
