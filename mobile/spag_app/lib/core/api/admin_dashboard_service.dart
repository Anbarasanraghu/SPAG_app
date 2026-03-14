import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../features/auth/services/auth_service.dart';
import '../models/admin_dashboard.dart';
import './api_config.dart';
import '../services/installation_event_service.dart';

class AdminDashboardService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<AdminDashboardStats> fetchDashboardStats() async {
    final token = await AuthService.getToken();

    debugPrint("[AdminDashboardService] ========== API CALL START ==========");
    debugPrint("[AdminDashboardService] TOKEN => ${token?.substring(0, 20)}...");

    if (token == null || token.isEmpty) {
      throw Exception("No token found");
    }

    final url = "$baseUrl/admin/dashboard";
    debugPrint("[AdminDashboardService] URL => $url");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("[AdminDashboardService] HTTP STATUS => ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        debugPrint("[AdminDashboardService] DECODED JSON TYPE: ${jsonData.runtimeType}");

        final stats = AdminDashboardStats.fromJson(jsonData);

        debugPrint("[AdminDashboardService] FINAL PARSED => totalUsers=${stats.totalUsers}, pending=${stats.pendingServices}, requests=${stats.productRequests}");
        debugPrint("[AdminDashboardService] ========== API CALL END ==========");

        return stats;
      } else {
        debugPrint("[AdminDashboardService] HTTP STATUS => ${response.statusCode}");
        debugPrint("[AdminDashboardService] RAW RESPONSE BODY:");
        debugPrint(response.body);
        throw Exception("Failed to load admin dashboard stats (Status: ${response.statusCode})");
      }
    } catch (e) {
      debugPrint("[AdminDashboardService] NETWORK ERROR: $e");
      throw Exception("Network error: $e");
    }
  }

  /// 🔹 Listen to installation completion events and refresh dashboard
  /// Call this in your admin dashboard screen to auto-refresh on completion
  static ValueNotifier<int?> listenToInstallationUpdates() {
    debugPrint("[AdminDashboardService] Listening to installation events");
    return InstallationEventService.installationCompletedNotifier;
  }
}
