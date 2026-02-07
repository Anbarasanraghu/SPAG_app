import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/admin_customer.dart';
import '../../auth/services/auth_service.dart';

class AdminCustomerService {
  static const String baseUrl = "http://localhost:8000";

  static Future<List<AdminCustomer>> fetchCustomers() async {
    final token = await AuthService.getToken();

    debugPrint("CUSTOMERS TOKEN => $token");

    final response = await http.get(
      Uri.parse("$baseUrl/admin/customers"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    debugPrint("CUSTOMERS STATUS => ${response.statusCode}");
    debugPrint("CUSTOMERS BODY => ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load customers");
    }

    final List decoded = jsonDecode(response.body);
    return decoded.map((e) => AdminCustomer.fromJson(e)).toList();
  }
}
