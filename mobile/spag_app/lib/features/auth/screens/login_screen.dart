import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../../auth/services/auth_service.dart';
import '../../customer/screens/customer_profile_form_screen.dart';
import '../../customer/screens/customer_dashboard_screen.dart';
import '../../customer/screens/customer_main_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../technician/screens/technician_home_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final authController = AuthController();
  bool loading = false;
  bool obscure = true;

  Future<void> login() async {
    setState(() => loading = true);
    try {
      final resp = await authController.login(phoneController.text.trim(), passwordController.text);

      debugPrint('Login response: token=${resp.token.substring(0,10)}..., role=${resp.role}, profileExists=${resp.profileExists}');

      await AuthService.saveToken(resp.token);
      await AuthService.saveRole(resp.role);

      if (!mounted) return;

      // Route based on role - but since app opens to catalog, just return auth data
      // Widget nextScreen;
      // switch (resp.role) {
      //   case 'admin':
      //     nextScreen = const AdminDashboardScreen();
      //     break;
      //   case 'technician':
      //     nextScreen = const TechnicianHomeScreen();
      //     break;
      //   case 'customer':
      //   default:
      //     if (!resp.profileExists) {
      //       nextScreen = const CustomerProfileFormScreen();
      //     } else {
      //       nextScreen = const CustomerDashboardScreen();
      //     }
      // }

      // Actually, let's route based on role after login
      debugPrint('[LoginScreen] Routing based on role: ${resp.role}');
      Widget nextScreen;
      switch (resp.role) {
        case 'admin':
        case 'Admin':
          debugPrint('[LoginScreen] Routing to AdminDashboardScreen');
          nextScreen = const AdminDashboardScreen();
          break;
        case 'technician':
        case 'Technician':
          debugPrint('[LoginScreen] Routing to TechnicianHomeScreen');
          nextScreen = const TechnicianHomeScreen();
          break;
        case 'customer':
        case 'Customer':
        default:
          if (!resp.profileExists) {
            debugPrint('[LoginScreen] Routing to CustomerProfileFormScreen');
            nextScreen = const CustomerProfileFormScreen();
          } else {
            debugPrint('[LoginScreen] Routing to CustomerMainScreen');
            nextScreen = CustomerMainScreen(); // Go to catalog for customers
          }
      }

      if (!mounted) {
        debugPrint('[LoginScreen] Widget not mounted, skipping navigation');
        return;
      }
      debugPrint('[LoginScreen] Navigating to ${nextScreen.runtimeType}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );

      // Instead, pop with auth response to let caller handle
      Navigator.pop(context, resp);
    } catch (e, st) {
      debugPrint('Login error: $e\n$st');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Login failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1F36),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Welcome Section
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
                        Icons.login,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Welcome Back!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Enter your mobile number to continue",
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

              // Input Card
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
                    // Label
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
                          "Mobile Number",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1F36),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Phone Input Field
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
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1F36),
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter 10-digit mobile number",
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 15,
                          ),
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.phone_outlined,
                              color: Color(0xFF6366F1),
                              size: 22,
                            ),
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

              // Password Card
              const SizedBox(height: 16),
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
                    const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                      ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: obscure,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A1F36)),
                        decoration: InputDecoration(
                          hintText: 'Enter password',
                          prefixIcon: Container(padding: const EdgeInsets.all(12), child: const Icon(Icons.lock_outline, color: Color(0xFF6366F1), size: 22)),
                          suffixIcon: IconButton(
                            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => obscure = !obscure),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  ),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Login Button
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
                  onPressed: loading ? null : login,
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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Register UI removed: minimal signup occurs from Catalog request flow
            ],
          ),
        ),
      ),
    );
  }
}