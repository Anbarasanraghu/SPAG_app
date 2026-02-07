import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/services/auth_service.dart';
import '../models/service_detail.dart';

class ServiceDetailService {
  static const String baseUrl = "http://localhost:8000";

  static Future<ServiceDetail> fetchServiceDetail(int serviceId) async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token missing");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/admin/services/$serviceId/details"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load service detail");
    }

    return ServiceDetail.fromJson(jsonDecode(response.body));
  }
}
