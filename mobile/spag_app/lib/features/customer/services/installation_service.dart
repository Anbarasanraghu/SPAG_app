import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api/api_config.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/services/installation_event_service.dart';

class InstallationService {
  static Future<List<dynamic>> getCustomerInstallations(int customerId) async {
    final token = await AuthService.getToken();
    
    if (token == null || token.isEmpty) {
      throw Exception("Token missing");
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/installations/customer/$customerId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load installations');
    }

    return jsonDecode(response.body);
  }

  static Future<void> createInstallation({
    required int customerId,
    required int purifierModelId,
    required String installDate,
  }) async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token missing");
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/installations/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'customer_id': customerId,
        'purifier_model_id': purifierModelId,
        'install_date': installDate,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create installation');
    }
  }

  /// 🔹 Get notification listener for installation completion
  /// Call this in screens to auto-refresh when an installation is completed
  static dynamic get installationUpdatedNotifier =>
      InstallationEventService.installationCompletedNotifier;
}
