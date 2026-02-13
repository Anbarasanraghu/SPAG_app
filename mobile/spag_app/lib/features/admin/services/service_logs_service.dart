import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/api/api_config.dart';
import '../../auth/services/auth_service.dart';

class ServiceLogsService {
  /// Get service status logs (all status changes for a service)
  static Future<List<dynamic>> getServiceStatusLogs(int serviceId) async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token missing");
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/admin/services/$serviceId/status-logs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('STATUS LOGS STATUS => ${response.statusCode}');
    debugPrint('STATUS LOGS BODY => ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to load service status logs');
    }

    return jsonDecode(response.body);
  }

  /// Get all service status logs
  static Future<List<dynamic>> getAllServiceStatusLogs() async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token missing");
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/admin/services/status-logs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('ALL STATUS LOGS STATUS => ${response.statusCode}');
    debugPrint('ALL STATUS LOGS BODY => ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to load all service status logs');
    }

    return jsonDecode(response.body);
  }

  /// Get technician activity logs (all actions by technician)
  static Future<List<dynamic>> getTechnicianActivityLogs(int technicianId) async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token missing");
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/admin/technicians/$technicianId/activity-logs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('ACTIVITY LOGS STATUS => ${response.statusCode}');
    debugPrint('ACTIVITY LOGS BODY => ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to load technician activity logs');
    }

    return jsonDecode(response.body);
  }

  /// Get all technician activity logs
  static Future<List<dynamic>> getAllTechnicianActivityLogs() async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token missing");
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/admin/technicians/activity-logs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('ALL ACTIVITY LOGS STATUS => ${response.statusCode}');
    debugPrint('ALL ACTIVITY LOGS BODY => ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to load all technician activity logs');
    }

    return jsonDecode(response.body);
  }
}
