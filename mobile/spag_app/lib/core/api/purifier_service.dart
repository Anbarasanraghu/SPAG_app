import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/purifier_model.dart';
import 'api_config.dart';
import '../../features/auth/services/auth_service.dart';

class PurifierService {
  static Future<List<PurifierModel>> listModels() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/purifier-models'),
      headers: token == null
          ? {'Content-Type': 'application/json'}
          : {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch purifier models');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => PurifierModel.fromJson(e)).toList();
  }

  static Future<void> requestProduct(int purifierModelId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/purifier-models/product-requests?purifier_model_id=$purifierModelId');

    final response = await http.post(
      url,
      headers: token == null
          ? {'Content-Type': 'application/json'}
          : {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit product request');
    }
  }
}