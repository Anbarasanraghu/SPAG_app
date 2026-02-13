import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/api/api_config.dart';
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
  static Future<void> completeInstallation(int requestId) async {
    final token = await AuthService.getToken();

    try {
      final response = await http.put(
        Uri.parse(
          "$baseUrl/technician/installations/$requestId/complete",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("Complete Installation Response Status: ${response.statusCode}");

      if (response.statusCode != 200) {
        throw Exception(
          "Failed to complete installation (${response.statusCode}): ${response.body}",
        );
      }
    } catch (e) {
      debugPrint("Error completing installation: $e");
      rethrow;
    }
  }
}
