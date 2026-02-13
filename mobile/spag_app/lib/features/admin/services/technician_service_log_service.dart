import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/technician_service_log.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/api/api_config.dart';
import '../models/service_status_log.dart';
import '../models/technician_activity_log.dart';

class TechnicianServiceLogService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// 🔹 Fetch technician service logs (Admin)
  static Future<List<TechnicianServiceLog>> fetchLogs() async {
    final token = await AuthService.getToken();

    debugPrint("TECH LOG TOKEN => $token");

    if (token == null || token.isEmpty) {
      throw Exception("Token missing");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/technician/services"),
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

  /// 🔹 Fetch status logs for a service (admin)
  static Future<List<ServiceStatusLog>> fetchStatusLogsForService(int serviceId) async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) throw Exception('Token missing');

    final response = await http.get(
      Uri.parse('$baseUrl/admin/services/status-logs?service_id=$serviceId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load status logs');
    }

    final List decoded = jsonDecode(response.body);
    return decoded.map((e) => ServiceStatusLog.fromJson(e)).toList();
  }

  /// 🔹 Fetch technician activity logs for a technician (admin)
  static Future<List<TechnicianActivityLog>> fetchTechnicianActivityLogs(int technicianId) async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) throw Exception('Token missing');

    final response = await http.get(
      Uri.parse('$baseUrl/technicians/$technicianId/activity-logs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load technician activity logs');
    }

    final List decoded = jsonDecode(response.body);
    return decoded.map((e) => TechnicianActivityLog.fromJson(e)).toList();
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
