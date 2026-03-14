import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/admin_user.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/api/api_config.dart';

class AdminUserService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Fetch all users (ADMIN ONLY)
  static Future<List<AdminUser>> fetchUsers() async {
    final token = await AuthService.getToken();

    debugPrint("FETCH USERS TOKEN => $token");

    if (token == null || token.isEmpty) {
      throw Exception("Token is NULL before API call");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/admin/users"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    debugPrint("STATUS: ${response.statusCode}");
    debugPrint("BODY: ${response.body}");

    if (response.statusCode == 401) {
      throw Exception("Unauthorized – token missing or expired");
    }

    if (response.statusCode != 200) {
      throw Exception("Failed to load users");
    }

    // ✅ BACKEND RETURNS A PURE LIST
    final List decoded = jsonDecode(response.body);

    return decoded
        .map((e) => AdminUser.fromJson(e))
        .toList();
  }

  /// Update user role (ADMIN ONLY)
  static Future<void> updateUserRole({
    required int userId,
    required String role,
  }) async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token is NULL before API call");
    }

    final response = await http.put(
      Uri.parse("$baseUrl/admin/users/$userId/role?role=$role"), // 👈 QUERY PARAM
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    debugPrint("UPDATE ROLE STATUS => ${response.statusCode}");
    debugPrint("UPDATE ROLE BODY => ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to update role");
    }
  }
}

