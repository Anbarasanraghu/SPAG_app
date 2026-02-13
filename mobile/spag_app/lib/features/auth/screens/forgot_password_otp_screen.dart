import 'package:flutter/material.dart';
import 'dart:async';
import '../controller/auth_controller.dart';
import 'reset_password_screen.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String phone;

  const ForgotPasswordOtpScreen({super.key, required this.phone});

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final otpController = TextEditingController();
  final authController = AuthController();
  bool loading = false;
  int resendCountdown = 0;
  int otpExpiry = 300; // 5 minutes in seconds
  late Timer resendTimer;
  late Timer expiryTimer;

  @override
  void initState() {
    super.initState();
    startResendCountdown();
    startExpiryCountdown();
  }

  void startResendCountdown() {
    resendCountdown = 30;
    resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          resendCountdown--;
          if (resendCountdown <= 0) {
            resendTimer.cancel();
          }
        });
      }
    });
  }

  void startExpiryCountdown() {
    otpExpiry = 300;
    expiryTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          otpExpiry--;
          if (otpExpiry <= 0) {
            expiryTimer.cancel();
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('OTP Expired'),
                content: const Text('The OTP has expired. Please request a new one.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        });
      }
    });
  }

  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      await authController.verifyResetOtp(widget.phone, otpController.text.trim());

      resendTimer.cancel();
      expiryTimer.cancel();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(phone: widget.phone),
        ),
      );
    } catch (e) {
      debugPrint('OTP verification error: $e');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> resendOtp() async {
    setState(() => loading = true);
    try {
      await authController.forgotPassword(widget.phone);
      startResendCountdown();
      startExpiryCountdown();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent successfully')),
      );
    } catch (e) {
      debugPrint('Resend OTP error: $e');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = otpExpiry ~/ 60;
    final seconds = otpExpiry % 60;
    final expiryText = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'OTP Verification',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the OTP sent to ${widget.phone}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6366F1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'OTP Code',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1F36),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Expires: $expiryText',
                          style: TextStyle(
                            fontSize: 12,
                            color: otpExpiry < 60 ? Colors.red : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1F36),
                          letterSpacing: 4,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '------',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 18,
                            letterSpacing: 4,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          counterText: '',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: (loading || otpExpiry <= 0) ? null : verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Verify OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: resendCountdown > 0
                    ? Text(
                        'Resend OTP in $resendCountdown seconds',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      )
                    : TextButton(
                        onPressed: loading ? null : resendOtp,
                        child: const Text('Didn\'t receive OTP? Resend'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    otpController.dispose();
    resendTimer.cancel();
    expiryTimer.cancel();
    super.dispose();
  }
}
