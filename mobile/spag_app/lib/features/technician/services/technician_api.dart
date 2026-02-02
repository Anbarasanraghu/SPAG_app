import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api/api_config.dart';
import '../models/technician_service.dart';
import '../models/customer_info.dart';

class TechnicianApi {
  static Future<List<TechnicianService>> getUpcomingServices() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/services/upcoming'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data
          .map((e) => TechnicianService.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load services');
    }
  }

  static Future<CustomerInfo> getCustomerInfo(int customerId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/customers/$customerId'),
    );

    if (response.statusCode == 200) {
      return CustomerInfo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load customer info');
    }
  }

  static Future<void> completeService({
    required int serviceId,
    required int customerId,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/services/update'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
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

  
