import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/api/api_config.dart';
import '../../../core/services/installation_event_service.dart';
import '../models/installation_job.dart';

class InstallationService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// 🔹 Get Assigned Installations
  static Future<List<InstallationJob>> fetchInstallations() async {
    final token = await AuthService.getToken();

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/technician/installations"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("Installation Jobs Response Status: ${response.statusCode}");
      debugPrint("Installation Jobs Response Body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          "Failed to load installations (${response.statusCode}): ${response.body}",
        );
      }

      final List<dynamic> data = jsonDecode(response.body);

      debugPrint("Parsed ${data.length} installation jobs");

      return data
          .map((e) {
            try {
              return InstallationJob.fromJson(e as Map<String, dynamic>);
            } catch (parseError) {
              debugPrint("Error parsing job: $parseError, data: $e");
              rethrow;
            }
          })
          .toList();
    } catch (e) {
      debugPrint("Error fetching installations: $e");
      rethrow;
    }
  }

  /// 🔹 Complete Installation
  static Future<void> completeInstallation(
    int requestId,
    InstallationJob job,
    Map<String, dynamic> details,
  ) async {
    final token = await AuthService.getToken();

    try {
      final payload = <String, dynamic>{
        ...details,
        "purifier_model_id": job.purifierModelId,
        "notes": details["notes"] ?? "Installation completed successfully",
      };

      debugPrint("[CompleteInstallation] Final payload: $payload");

      final uri = Uri.parse(
        "$baseUrl/technician/installations/$requestId/complete",
      );

      final response = await http.put(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
        body: jsonEncode(payload),
      );

      debugPrint(
        "Complete Installation Response Status: ${response.statusCode}",
      );
      debugPrint(
        "Complete Installation Response Body: ${response.body}",
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          "Failed to complete installation (${response.statusCode}): ${response.body}",
        );
      }

      InstallationEventService.notifyInstallationCompleted(requestId);
      debugPrint(
        "[CompleteInstallation] Event broadcast for request $requestId",
      );
    } catch (e) {
      debugPrint("Error completing installation: $e");
      rethrow;
    }
  }
}