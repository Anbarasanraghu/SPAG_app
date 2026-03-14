import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/purifier_model.dart';
import 'api_config.dart';
import '../../features/auth/services/auth_service.dart';

class PurifierService {
  static Future<List<PurifierModel>> listModels() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/purifier-models'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch purifier models');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => PurifierModel.fromJson(e)).toList();
  }

  static Future<Map<String, dynamic>?> requestProduct(int purifierModelId, {String? mobile, String? gmail, String? password}) async {
    final token = await AuthService.getToken();
    final isAnonymous = token == null;

    if (isAnonymous) {
      if (mobile == null || gmail == null || password == null) {
        throw Exception('Mobile, gmail, and password required for anonymous request');
      }
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/purifier-models/product-requests'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'purifier_model_id': purifierModelId,
          'mobile_number': mobile,
          'gmail': gmail,
          'password': password,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to submit product request: ${response.body}');
      }

      final data = jsonDecode(response.body);
      // Store token if returned
      if (data['token'] != null) {
        await AuthService.saveToken(data['token']);
        await AuthService.saveRole('customer'); // assume customer
      }
      return data;
    } else {
      // Authenticated
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/purifier-models/product-requests?purifier_model_id=$purifierModelId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to submit product request: ${response.body}');
      }

      final data = jsonDecode(response.body);
      return data;
    }
  }

  static Future<List<dynamic>> listUserRequests() async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/purifier-models/product-requests');

    final response = await http.get(
      url,
      headers: token == null
          ? {'Content-Type': 'application/json'}
          : {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch product requests');
    }

    final List data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }
}
