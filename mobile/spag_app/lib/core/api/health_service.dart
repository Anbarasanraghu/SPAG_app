import 'package:http/http.dart' as http;
import 'api_config.dart';

class HealthService {
  static Future<bool> checkBackend() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/'),
    );

    return response.statusCode == 200;
  }
}

