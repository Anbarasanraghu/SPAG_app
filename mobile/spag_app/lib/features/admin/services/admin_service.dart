import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/api/api_config.dart';
import '../../auth/services/auth_service.dart';

class AdminService {
  // -------------------------------
  // GET PRODUCT REQUESTS
  // -------------------------------
  static Future<List<dynamic>> getProductRequests() async {
    final token = await AuthService.getToken();

    debugPrint('');
    debugPrint('╔═══════════════════════════════════════════════════════════════╗');
    debugPrint('║          FETCHING PRODUCT REQUESTS FROM API                   ║');
    debugPrint('╚═══════════════════════════════════════════════════════════════╝');
    debugPrint('URL: ${ApiConfig.baseUrl}/admin/product-requests');
    debugPrint('Token: ${token != null ? 'Present' : 'Missing'}');
    
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/admin/product-requests'),
      headers: token == null
          ? {'Content-Type': 'application/json'}
          : {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
    );

    debugPrint('');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response Body:');
    debugPrint(response.body);
    debugPrint('');

    if (response.statusCode != 200) {
      debugPrint('❌ ERROR: Failed to load product requests');
      throw Exception('Failed to load product requests');
    }

    final data = jsonDecode(response.body);
    debugPrint('✅ Successfully parsed response');
    debugPrint('Number of requests: ${(data as List).length}');
    
    if ((data as List).isNotEmpty) {
      debugPrint('');
      debugPrint('First Request Data Structure:');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      final firstRequest = jsonEncode(data.first);
      debugPrint(firstRequest);
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }

    return data;
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

