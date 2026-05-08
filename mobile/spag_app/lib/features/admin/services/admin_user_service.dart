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

  /// Create a new user (ADMIN ONLY)
  static Future<AdminUser> createUser({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token is NULL before API call");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/admin/users"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": name,
        "phone": phone,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    debugPrint("CREATE USER STATUS => ${response.statusCode}");
    debugPrint("CREATE USER BODY => ${response.body}");

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? "Failed to create user");
    }

    final data = jsonDecode(response.body);
    return AdminUser.fromJson(data);
  }

  /// Update user details (ADMIN ONLY)
  static Future<AdminUser> updateUser({
    required int userId,
    String? name,
    String? phone,
    String? email,
    String? role,
  }) async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token is NULL before API call");
    }

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (email != null) body['email'] = email;
    if (role != null) body['role'] = role;

    final response = await http.put(
      Uri.parse("$baseUrl/admin/users/$userId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    debugPrint("UPDATE USER STATUS => ${response.statusCode}");
    debugPrint("UPDATE USER BODY => ${response.body}");

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? "Failed to update user");
    }

    final data = jsonDecode(response.body);
    return AdminUser.fromJson(data);
  }

  /// Delete a user (ADMIN ONLY)
  static Future<void> deleteUser(int userId) async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token is NULL before API call");
    }

    final response = await http.delete(
      Uri.parse("$baseUrl/admin/users/$userId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    debugPrint("DELETE USER STATUS => ${response.statusCode}");
    debugPrint("DELETE USER BODY => ${response.body}");

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? "Failed to delete user");
    }
  }
}

