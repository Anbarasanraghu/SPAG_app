import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/pending_service.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/api/api_config.dart';

class PendingServiceService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<List<PendingService>> fetchPendingServices() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/admin/services/pending"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    debugPrint("PENDING STATUS => ${response.statusCode}");
    debugPrint("PENDING BODY => ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load pending services");
    }

    final List decoded = jsonDecode(response.body);
    return decoded.map((e) => PendingService.fromJson(e)).toList();
  }

  static Future<void> assignTechnician({
    required int serviceId,
    required int technicianId,
  }) async {
    final token = await AuthService.getToken();

    final uri = Uri.parse(
      "$baseUrl/admin/services/$serviceId/assign?technician_id=$technicianId",
    );

    final response = await http.put(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    debugPrint('Assign Technician -> ${uri.toString()}');
    debugPrint('Assign Technician STATUS -> ${response.statusCode}');
    debugPrint('Assign Technician BODY -> ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to assign technician: ${response.statusCode} ${response.body}");
    }
  }

  /// Update service status (called when technician completes installation)
  static Future<void> updateServiceStatus({
    required int serviceId,
    required String status,
  }) async {
    final token = await AuthService.getToken();

    final uri = Uri.parse(
      "$baseUrl/admin/services/$serviceId/status",
    );

    final response = await http.put(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "status": status,
      }),
    );

    debugPrint('Update Service Status -> ${uri.toString()}');
    debugPrint('Update Service Status REQUEST -> status=$status');
    debugPrint('Update Service Status RESPONSE STATUS -> ${response.statusCode}');
    debugPrint('Update Service Status RESPONSE BODY -> ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to update service status: ${response.statusCode} ${response.body}");
    }
  }
}

