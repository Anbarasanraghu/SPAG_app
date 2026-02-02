import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import 'otp_screen.dart';

class MobileInputScreen extends StatefulWidget {
  const MobileInputScreen({super.key});

  @override
  State<MobileInputScreen> createState() => _MobileInputScreenState();
}

class _MobileInputScreenState extends State<MobileInputScreen> {
  final mobileController = TextEditingController();
  final authController = AuthController();

  void sendOtp() async {
    await authController.sendOtp(mobileController.text);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(mobile: mobileController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Mobile Number"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendOtp,
              child: const Text("Send OTP"),
            )
          ],
        ),
      ),
    );
  }
}
