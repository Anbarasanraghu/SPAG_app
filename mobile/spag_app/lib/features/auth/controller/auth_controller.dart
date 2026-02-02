import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/auth_api.dart';

class AuthController {
  final storage = const FlutterSecureStorage();

  Future<void> sendOtp(String mobile) async {
    await AuthApi.sendOtp(mobile);
  }

  Future<String> verifyOtp(String mobile, String otp) async {
  final data = await AuthApi.verifyOtp(mobile, otp);

  if (data['token'] == null || data['role'] == null) {
    throw Exception("Token or role missing from response");
  }

  await storage.write(key: 'token', value: data['token']);
  await storage.write(key: 'role', value: data['role']);

  final savedToken = await storage.read(key: 'token');
  print("SAVED TOKEN => $savedToken");

  return data['role']; // customer | technician
}
}