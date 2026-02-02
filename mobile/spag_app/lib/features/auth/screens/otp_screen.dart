import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../../customer/customer_dashboard_screen.dart';
import '../../technician/screens/technician_home_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';

class OtpScreen extends StatefulWidget {
  final String mobile;
  const OtpScreen({super.key, required this.mobile});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpController = TextEditingController();
  final authController = AuthController();
  bool loading = false;

  void verifyOtp() async {
    setState(() => loading = true);
    try {
      // Debug logs to ensure function is called and inputs are correct
      print('verifyOtp called for mobile=${widget.mobile} otp=${otpController.text}');

      final role = await authController.verifyOtp(
        widget.mobile,
        otpController.text,
      );

      // Use debugPrint which is more reliable for long messages
      debugPrint('ROLE FROM BACKEND => $role');

      if (!mounted) return;

      if (role == 'technician') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const TechnicianHomeScreen(),
          ),
        );
      } else if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboardScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CustomerDashboardScreen(),
          ),
        );
      }
    } catch (e, st) {
      // Print the error so you can see it in logs
      debugPrint('verifyOtp error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error verifying OTP: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("OTP sent to ${widget.mobile}"),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter OTP"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : verifyOtp,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }
}
