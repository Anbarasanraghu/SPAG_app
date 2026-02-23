import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import '../../customer/services/customer_profile_service.dart';
import '../screens/customer_dashboard_screen.dart';
import '../../auth/controller/auth_controller.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../technician/screens/technician_home_screen.dart';
import '../../auth/screens/login_screen.dart';

// ─── COLOUR TOKENS ───────────────────────────────────────
// bg: #F5F9FF  panels: #FFFFFF  surface: #EAF3FF
// accent: #2A8FD4  mid: #5AABDE  soft: #C4DFF5
// text: #0D2A3F  muted: #6B8FA8  hairline: #D6E8F5

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _loading = true;
  String? _token;
  final _authController = AuthController();

  static const Color _bg       = Color(0xFFF5F9FF);
  static const Color _panel    = Color(0xFFFFFFFF);
  static const Color _surface  = Color(0xFFEAF3FF);
  static const Color _accent   = Color(0xFF2A8FD4);
  static const Color _mid      = Color(0xFF5AABDE);
  static const Color _soft     = Color(0xFFC4DFF5);
  static const Color _text     = Color(0xFF0D2A3F);
  static const Color _muted    = Color(0xFF6B8FA8);
  static const Color _hairline = Color(0xFFD6E8F5);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final token = await AuthService.getToken();
    final role = await AuthService.getRole();

    if (role == 'admin' || role == 'Admin' || role == 'technician' || role == 'Technician') {
      setState(() {
        _token = token;
        _loading = false;
      });
      return;
    }

    setState(() {
      _token = token;
      _loading = false;
    });
  }

  Future<void> _goToDashboardIfReady() async {
    if (_token == null) return;

    final role = await AuthService.getRole();
    if (role == 'admin' || role == 'Admin') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
      return;
    } else if (role == 'technician' || role == 'Technician') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TechnicianHomeScreen()));
      return;
    }

    final exists = await CustomerProfileService.profileExists();
    if (!mounted) return;
    if (!exists) {
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
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.access_time_rounded, color: Color(0xFFD4842A), size: 22),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Installation Pending',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _text,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your installation is pending. Please wait for technician.',
                  style: TextStyle(fontSize: 12, color: _muted, height: 1.4),
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
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()));
    }
  }

  Future<void> _showLogin() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    if (result is AuthResponse) {
      await AuthService.saveToken(result.token);
      await AuthService.saveRole(result.role);
      setState(() => _token = result.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── LOADING ──
    if (_loading) {
      return Container(
        color: _bg,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _panel,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _accent.withOpacity(0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(_accent),
            ),
          ),
        ),
      );
    }

    // ── NOT LOGGED IN ──
    if (_token == null) {
      return Container(
        color: _bg,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Illustration
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline_rounded, size: 40, color: _soft),
                ),
                const SizedBox(height: 16),

                // Eyebrow
                const Text(
                  'PROFILE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _muted,
                    letterSpacing: 2.2,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _text,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to access your account and track your purifier.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: _muted, height: 1.5),
                ),
                const SizedBox(height: 24),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _showLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded, size: 15),
                        SizedBox(width: 8),
                        Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Hint text
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _hairline),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 12, color: _muted),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Or request a product from the Catalog to register',
                          style: TextStyle(
                            fontSize: 10,
                            color: _muted,
                            fontFamily: 'monospace',
                            letterSpacing: 0.2,
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

    // ── LOGGED IN ──
    return Container(
      color: _bg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_accent, Color(0xFF1A6BA8)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.person_rounded, size: 36, color: Colors.white),
              ),
              const SizedBox(height: 14),

              const Text(
                'ACCOUNT',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: _muted,
                  letterSpacing: 2.2,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'You\'re signed in',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _text,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 24),

              // Card with actions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _hairline),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Open Dashboard
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _goToDashboardIfReady,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.dashboard_rounded, size: 15),
                            SizedBox(width: 8),
                            Text(
                              'OPEN DASHBOARD',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.6,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Divider
                    Container(height: 1, color: _hairline),
                    const SizedBox(height: 8),

                    // Logout
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () async {
                          await AuthService.logout();
                          setState(() => _token = null);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _surface,
                          foregroundColor: const Color(0xFFE05A5A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: _hairline),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded, size: 15),
                            SizedBox(width: 8),
                            Text(
                              'LOGOUT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.8,
                                fontFamily: 'monospace',
                                color: Color(0xFFE05A5A),
                              ),
                            ),
                          ],
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