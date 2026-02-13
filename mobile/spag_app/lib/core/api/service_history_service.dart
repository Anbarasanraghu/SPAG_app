import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../features/auth/services/auth_service.dart';
import '../models/dashboard.dart';
import './api_config.dart';

class ServiceHistoryService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Fetch service history for the current customer
  static Future<List<ServiceItem>> fetchServiceHistory() async {
    final token = await AuthService.getToken();

    debugPrint("[ServiceHistoryService] ========== FETCH START ==========");
    debugPrint("[ServiceHistoryService] TOKEN => ${token?.substring(0, 20)}...");

    if (token == null || token.isEmpty) {
      throw Exception("No token found");
    }

    // Try multiple possible endpoints
    final endpoints = [
      "$baseUrl/customer/services",
      "$baseUrl/services",
      "$baseUrl/dashboard/services",
      "$baseUrl/service-history",
    ];

    for (final url in endpoints) {
      try {
        debugPrint("[ServiceHistoryService] Trying endpoint: $url");
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () => http.Response('{"error": "timeout"}', 408),
        );

        debugPrint("[ServiceHistoryService] $url => Status: ${response.statusCode}");

        if (response.statusCode == 200) {
          debugPrint("[ServiceHistoryService] ✅ SUCCESS with: $url");
          debugPrint("[ServiceHistoryService] Response: ${response.body}");
          
          final jsonData = jsonDecode(response.body);
          
          // Handle different response formats
          List<ServiceItem> services = [];
          
          if (jsonData is List) {
            // Direct list response
            debugPrint("[ServiceHistoryService] Parsing as direct list");
            services = (jsonData)
                .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
                .toList();
          } else if (jsonData is Map) {
            // Object with services array
            debugPrint("[ServiceHistoryService] Parsing as object - looking for services array");
            final servicesList = jsonData['services'] ?? jsonData['data'] ?? jsonData['records'] ?? [];
            
            debugPrint("[ServiceHistoryService] Found servicesList: ${servicesList.runtimeType}, length: ${servicesList is List ? (servicesList as List).length : 0}");
            
            if (servicesList is List) {
              services = servicesList
                  .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
                  .toList();
            }
          }
          
          debugPrint("[ServiceHistoryService] ✅ Parsed ${services.length} services from $url");
          debugPrint("[ServiceHistoryService] ========== FETCH END (SUCCESS) ==========");
          return services;
        } else if (response.statusCode == 404) {
          debugPrint("[ServiceHistoryService] ⚠️ Endpoint not found: $url");
        } else {
          debugPrint("[ServiceHistoryService] ⚠️ Endpoint returned ${response.statusCode}: $url");
        }
      } catch (e) {
        debugPrint("[ServiceHistoryService] ❌ Error with $url: $e");
      }
    }

    debugPrint("[ServiceHistoryService] ⚠️ All endpoints failed or returned 404, returning empty list");
    debugPrint("[ServiceHistoryService] ========== FETCH END (EMPTY) ==========");
    return [];
  }
}
