import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/dashboard.dart';
import '../api/api_config.dart';

class DashboardService {
  static const storage = FlutterSecureStorage();

  static Future<CustomerDashboard> fetchDashboard() async {
    final token = await storage.read(key: 'token');

    if (token == null) {
      throw Exception("No token found");
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/dashboard/customer'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("API error ${response.statusCode}");
    }

    return CustomerDashboard.fromJson(
      jsonDecode(response.body),
    );
  }
}
