import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/technician_service_log.dart';
import '../../auth/services/auth_service.dart';

class TechnicianServiceLogService {
  static const String baseUrl = "http://localhost:8000";

  /// 🔹 Fetch technician service logs (Admin)
  static Future<List<TechnicianServiceLog>> fetchLogs() async {
    final token = await AuthService.getToken();

    debugPrint("TECH LOG TOKEN => $token");

    if (token == null || token.isEmpty) {
      throw Exception("Token missing");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/admin/technician/services"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    debugPrint("TECH LOG STATUS => ${response.statusCode}");
    debugPrint("TECH LOG BODY => ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load technician logs");
    }

    final List decoded = jsonDecode(response.body);

    return decoded
        .map((e) => TechnicianServiceLog.fromJson(e))
        .toList();
  }

  /// 🔹 Update service status (ASSIGNED → COMPLETED)
  static Future<void> updateServiceStatus({
    required int serviceId,
    required String status, // COMPLETED
  }) async {
    final token = await AuthService.getToken();

    debugPrint("UPDATE STATUS TOKEN => $token");
    debugPrint("UPDATE STATUS => $status for service $serviceId");

    if (token == null || token.isEmpty) {
      throw Exception("Token missing");
    }

    final response = await http.put(
      Uri.parse(
        "$baseUrl/admin/services/$serviceId/status?status=$status",
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    debugPrint("UPDATE STATUS CODE => ${response.statusCode}");
    debugPrint("UPDATE STATUS BODY => ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to update service status");
    }
  }
}
