import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api/api_config.dart';
import '../../auth/services/auth_service.dart';

class AdminService {
  // -------------------------------
  // GET PRODUCT REQUESTS
  // -------------------------------
  static Future<List<dynamic>> getProductRequests() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/admin/product-requests'),
      headers: token == null
          ? {'Content-Type': 'application/json'}
          : {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load product requests');
    }

    return jsonDecode(response.body);
  }

  // -------------------------------
  // ASSIGN PRODUCT REQUEST TO TECHNICIAN
  // -------------------------------
  static Future<void> assignProductRequest({
    required int requestId,
    required int technicianUserId,
  }) async {
    final token = await AuthService.getToken();

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/admin/product-requests/$requestId/assign'
        '?technician_id=$technicianUserId',
      ),
      headers: token == null
          ? {'Content-Type': 'application/json'}
          : {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
    );

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to assign technician: ${response.statusCode} ${response.body}',
      );
    }
  }

  // -------------------------------
  // GET PENDING SERVICES
  // -------------------------------
  static Future<List<dynamic>> getPendingServices() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/admin/pending-services'),
      headers: token == null
          ? {'Content-Type': 'application/json'}
          : {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load pending services');
    }

    return jsonDecode(response.body);
  }
}

