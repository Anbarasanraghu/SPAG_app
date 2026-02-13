import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phone;

  const ResetPasswordScreen({super.key, required this.phone});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final authController = AuthController();
  bool loading = false;
  bool obscureNew = true;
  bool obscureConfirm = true;

  Future<void> resetPassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      await authController.resetPassword(widget.phone, newPasswordController.text);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Your password has been reset. Please login with your new password.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Reset password error: $e');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
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
                        Icons.lock_open,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Create New Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter a strong password to secure your account',
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
              // New Password
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
                    const Text(
                      'New Password',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1F36),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1F36),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter new password',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 15,
                          ),
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF6366F1),
                              size: 22,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey[600],
                            ),
                            onPressed: () => setState(() => obscureNew = !obscureNew),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Confirm Password
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
                    const Text(
                      'Confirm Password',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1F36),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1F36),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Confirm password',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 15,
                          ),
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF6366F1),
                              size: 22,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey[600],
                            ),
                            onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
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
                  onPressed: loading ? null : resetPassword,
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
                          'Reset Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
