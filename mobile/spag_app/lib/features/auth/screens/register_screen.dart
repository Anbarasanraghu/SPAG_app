import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final authController = AuthController();
  bool loading = false;
  bool obscure = true;

  Future<void> register() async {
    if (passwordController.text != confirmController.text) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Error'),
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    setState(() => loading = true);
    try {
      final data = await authController.register(
        nameController.text.trim(),
        phoneController.text.trim(),
        passwordController.text,
      );

      // If backend returns token, you may auto-login. For now, navigate back to login.
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Registration successful'),
          content: const Text('Please login with your credentials'),
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
    } catch (e, st) {
      debugPrint('Register error: $e\n$st');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Registration failed'),
          content: Text(e.toString()),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              TextField(controller: passwordController, obscureText: obscure, decoration: InputDecoration(labelText: 'Password', suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => obscure = !obscure)))),
              const SizedBox(height: 12),
              TextField(controller: confirmController, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: loading ? null : register, child: loading ? const CircularProgressIndicator() : const Text('Register')),
            ],
          ),
        ),
      ),
    );
  }
}
