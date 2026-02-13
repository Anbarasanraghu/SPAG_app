import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/api/api_config.dart';
import '../models/technician_service.dart';
import '../models/customer_info.dart';
import '../../auth/services/auth_service.dart';

class TechnicianApi {
  static Future<List<TechnicianService>> getUpcomingServices() async {
    final token = await AuthService.getToken();
    
    debugPrint("🔍 TechnicianApi: Token = $token");
    debugPrint("🔍 TechnicianApi: URL = ${ApiConfig.baseUrl}/services/upcoming");
    
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/services/upcoming'),
      headers: token == null
          ? {'Content-Type': 'application/json'}
          : {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
    );

    debugPrint("🔍 TechnicianApi: Status Code = ${response.statusCode}");
    debugPrint("🔍 TechnicianApi: Response Body = ${response.body}");

    if (response.statusCode == 200) {
      try {
        final List data = jsonDecode(response.body);
        debugPrint("🔍 TechnicianApi: Parsed ${data.length} services");
        
        final services = data
            .map((e) => TechnicianService.fromJson(e))
            .toList();
        
        debugPrint("🔍 TechnicianApi: Successfully created ${services.length} TechnicianService objects");
        return services;
      } catch (e) {
        debugPrint("❌ TechnicianApi: Parsing error = $e");
        throw Exception('Failed to parse services: $e');
      }
    } else {
      debugPrint("❌ TechnicianApi: HTTP error ${response.statusCode}");
      throw Exception('Failed to load services: ${response.statusCode} ${response.body}');
    }
  }

  static Future<CustomerInfo> getCustomerInfo(int customerId) async {
    final token = await AuthService.getToken();
    
    final uri = Uri.parse('${ApiConfig.baseUrl}/customers/$customerId');
    debugPrint("🔍 TechnicianApi.getCustomerInfo: GET $uri");

    final response = await http.get(
      uri,
      headers: token == null
          ? {'Content-Type': 'application/json'}
          : {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
    );

    debugPrint("🔍 TechnicianApi.getCustomerInfo: Status = ${response.statusCode}");
    debugPrint("🔍 TechnicianApi.getCustomerInfo: Body = ${response.body}");

    if (response.statusCode == 200) {
      try {
        return CustomerInfo.fromJson(jsonDecode(response.body));
      } catch (e) {
        debugPrint("❌ TechnicianApi.getCustomerInfo: Parsing error = $e");
        throw Exception('Failed to parse customer info: $e');
      }
    } else {
      throw Exception('Failed to load customer info: ${response.statusCode}');
    }
  }

  static Future<void> completeService({
    required int serviceId,
    required int customerId,
  }) async {
    final token = await AuthService.getToken();
    
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/services/update'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "service_id": serviceId,
        "customer_id": customerId,
        "status": "COMPLETED"
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Service update failed');
    }
  }
}

  
