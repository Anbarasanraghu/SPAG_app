import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../../auth/services/auth_service.dart';
import '../../customer/screens/customer_profile_form_screen.dart';
import '../../customer/screens/customer_main_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../technician/screens/technician_home_screen.dart';
import 'forgot_password_screen.dart';

// ─── COLOUR TOKENS ───────────────────────────────────────
// bg: #F5F9FF  panels: #FFFFFF  surface: #EAF3FF
// accent: #2A8FD4  mid: #5AABDE  soft: #C4DFF5
// text: #0D2A3F  muted: #6B8FA8  hairline: #D6E8F5

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController    = TextEditingController();
  final passwordController = TextEditingController();
  final authController     = AuthController();
  bool loading = false;
  bool obscure = true;

  static const Color _bg       = Color(0xFFF5F9FF);
  static const Color _panel    = Color(0xFFFFFFFF);
  static const Color _surface  = Color(0xFFEAF3FF);
  static const Color _accent   = Color(0xFF2A8FD4);
  static const Color _mid      = Color(0xFF5AABDE);
  static const Color _soft     = Color(0xFFC4DFF5);
  static const Color _text     = Color(0xFF0D2A3F);
  static const Color _muted    = Color(0xFF6B8FA8);
  static const Color _hairline = Color(0xFFD6E8F5);

  Future<void> login() async {
    setState(() => loading = true);
    try {
      final resp = await authController.login(
        phoneController.text.trim(),
        passwordController.text,
      );

      debugPrint('Login response: token=${resp.token.substring(0, 10)}..., role=${resp.role}, profileExists=${resp.profileExists}');

      await AuthService.saveToken(resp.token);
      await AuthService.saveRole(resp.role);

      if (!mounted) return;

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
            nextScreen = CustomerMainScreen();
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

      Navigator.pop(context, resp);
    } catch (e, st) {
      debugPrint('Login error: $e\n$st');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: _panel,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.error_outline_rounded, color: Color(0xFFE05A5A), size: 20),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Login Failed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  e.toString(),
                  style: const TextStyle(fontSize: 12, color: _muted, height: 1.4),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _surface,
                      foregroundColor: _accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: _soft),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        surfaceTintColor: _bg,
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: _text,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'AQUA SYSTEMS',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: _muted,
                letterSpacing: 2.2,
                fontFamily: 'monospace',
              ),
            ),
            SizedBox(height: 1),
            Text(
              'Sign In',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _text,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _hairline),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Hero banner ─────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_accent, Color(0xFF1A6BA8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Enter your mobile number to continue',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.80),
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Input card ───────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _hairline),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Mobile field ──
                    const Text(
                      'MOBILE NUMBER',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: _muted,
                        letterSpacing: 1.8,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 6),
                    _AquaField(
                      controller: phoneController,
                      hint: 'Enter 10-digit mobile number',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),

                    const SizedBox(height: 14),

                    // Hairline divider
                    Container(height: 1, color: _hairline),

                    const SizedBox(height: 14),

                    // ── Password field ──
                    const Text(
                      'PASSWORD',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: _muted,
                        letterSpacing: 1.8,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: passwordController,
                      obscureText: obscure,
                      style: const TextStyle(fontSize: 13, color: _text),
                      decoration: InputDecoration(
                        hintText: 'Enter password',
                        hintStyle: const TextStyle(fontSize: 12, color: _muted),
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: _accent, size: 18),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => obscure = !obscure),
                          child: Icon(
                            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: _muted,
                            size: 18,
                          ),
                        ),
                        filled: true,
                        fillColor: _surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: _hairline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: _mid, width: 1.5),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // ── Forgot password ──────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: _accent,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  ),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _accent,
                      fontFamily: 'monospace',
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Login button ─────────────────────────────────
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: loading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _soft,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_rounded, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Hint ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _hairline),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 12, color: _muted),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'New here? Request a product from the Catalog to register.',
                        style: TextStyle(
                          fontSize: 10,
                          color: _muted,
                          fontFamily: 'monospace',
                          letterSpacing: 0.2,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── REUSABLE AQUA TEXT FIELD ────────────────────────────
class _AquaField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final IconData prefixIcon;

  const _AquaField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, color: Color(0xFF0D2A3F)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF6B8FA8)),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF2A8FD4), size: 18),
        filled: true,
        fillColor: const Color(0xFFEAF3FF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD6E8F5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF5AABDE), width: 1.5),
        ),
        border: InputBorder.none,
      ),
    );
  }
}