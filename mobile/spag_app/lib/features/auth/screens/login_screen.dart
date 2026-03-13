import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/auth_controller.dart';
import '../../auth/services/auth_service.dart';
import '../../customer/screens/customer_profile_form_screen.dart';
import '../../customer/screens/customer_main_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../technician/screens/technician_home_screen.dart';
import 'forgot_password_screen.dart';

// ─── PALETTE (matches Admin Dashboard) ───────────────────────────────────────
const _bg       = Color(0xFFF5F4F0);
const _white    = Color(0xFFFFFFFF);
const _ink      = Color(0xFF111110);
const _ink2     = Color(0xFF8A8880);
const _darkPill = Color(0xFF1A1A18);
const _lavender = Color(0xFFD5CCFF);
const _mint     = Color(0xFFBDF0D8);
const _blush    = Color(0xFFF5C8D4);
const _sky      = Color(0xFFBFE0F5);
const _peach    = Color(0xFFF8DBBF);
const _sage     = Color(0xFFC8DFC0);

// ─────────────────────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController    = TextEditingController();
  final phoneController    = TextEditingController();
  final passwordController = TextEditingController();
  final authController     = AuthController();
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
          phoneController.text.trim(), passwordController.text);

      debugPrint(
          'Login response: token=${resp.token.substring(0, 10)}..., role=${resp.role}, profileExists=${resp.profileExists}');

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
    } catch (e, st) {
      debugPrint('Login error: $e\n$st');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: _bg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Login Failed',
              style: TextStyle(
                  fontWeight: FontWeight.w800, color: _ink, fontSize: 18)),
          content: Text(e.toString(),
              style: const TextStyle(color: _ink2, fontSize: 13)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: _darkPill,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text('OK',
                    style: TextStyle(
                        color: _white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: isWide ? _DesktopLayout(this) : _MobileLayout(this),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE LAYOUT
// ─────────────────────────────────────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final _LoginScreenState s;
  const _MobileLayout(this.s);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _HeroCard(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _FormCard(s),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DESKTOP LAYOUT
// ─────────────────────────────────────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  final _LoginScreenState s;
  const _DesktopLayout(this.s);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _HeroCard(tall: true),
          ),
        ),
        Expanded(
          flex: 5,
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: _FormCard(s),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO CARD
// ─────────────────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final bool tall;
  const _HeroCard({this.tall = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: tall
          ? const EdgeInsets.all(0)
          : const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        // ✅ FIX: Removed fixed height:220 — caused overflow on small screens.
        // Now uses constraints with a minimum height so it grows with content.
        height: tall ? double.infinity : null,
        constraints: tall ? null : const BoxConstraints(minHeight: 200),
        decoration: BoxDecoration(
          color: _darkPill,
          borderRadius: BorderRadius.circular(30),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          // ✅ FIX: Stack size must follow Column content, not clip it
          fit: StackFit.passthrough,
          children: [
            // decorative circles — positioned so they don't affect layout
            Positioned(
              top: -40,
              right: -20,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _lavender.withOpacity(0.18),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              right: 70,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _mint.withOpacity(0.15),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: 60,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _peach.withOpacity(0.12),
                ),
              ),
            ),
            // ✅ FIX: Main content in a non-positioned child so Stack sizes to it
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // ✅ FIX: mainAxisSize.min so Column only takes what it needs
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Secure Login badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _mint.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: _mint.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: _mint, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        const Text('Secure Login',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _mint)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Welcome Back title
                  const Text(
                    'Welcome\nBack!',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: _white,
                      height: 1.05,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Subtitle
                  const Text(
                    'Enter your credentials\nto continue.',
                    style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6A6A68),
                        height: 1.5,
                        fontWeight: FontWeight.w500),
                  ),
                  // ✅ FIX: Replaced Spacer() with fixed SizedBox.
                  // Spacer() inside a min-size Column causes overflow.
                  const SizedBox(height: 20),
                  // Pills
                  Row(
                    children: [
                      _HeroPill(label: '🔐 Secure', color: _lavender),
                      const SizedBox(width: 8),
                      _HeroPill(label: '⚡ Fast', color: _peach),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;
  final Color color;
  const _HeroPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FORM CARD
// ─────────────────────────────────────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final _LoginScreenState s;
  const _FormCard(this.s);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Sign In',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                    letterSpacing: -0.5)),
            Text('Quick & easy →',
                style: TextStyle(
                    fontSize: 12,
                    color: _ink2,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),

        _BentoField(
          accentColor: _sky,
          emoji: '📱',
          label: 'Mobile Number',
          child: _StyledInput(
            controller: s.phoneController,
            hint: 'Enter 10-digit mobile number',
            keyboard: TextInputType.phone,
          ),
        ),
        const SizedBox(height: 12),

        _BentoField(
          accentColor: _lavender,
          emoji: '🔒',
          label: 'Password',
          child: _StyledInput(
            controller: s.passwordController,
            hint: 'Enter your password',
            obscure: s.obscure,
            suffix: GestureDetector(
              onTap: () => s.setState(() => s.obscure = !s.obscure),
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Text(
                  s.obscure ? '👁️' : '🙈',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ForgotPasswordScreen()),
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _peach.withOpacity(0.4),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _ink),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        _LoginButton(loading: s.loading, onTap: s.login),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
                child:
                    _MiniChip(emoji: '🛡️', label: 'Secure', color: _sage)),
            const SizedBox(width: 10),
            Expanded(
                child: _MiniChip(
                    emoji: '⚙️', label: 'Role-based', color: _sky)),
            const SizedBox(width: 10),
            Expanded(
                child: _MiniChip(
                    emoji: '💧', label: 'PureCare', color: _mint)),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BENTO FIELD WRAPPER
// ─────────────────────────────────────────────────────────────────────────────
class _BentoField extends StatelessWidget {
  final Color accentColor;
  final String emoji;
  final String label;
  final Widget child;
  const _BentoField({
    required this.accentColor,
    required this.emoji,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _ink2)),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STYLED TEXT INPUT
// ─────────────────────────────────────────────────────────────────────────────
class _StyledInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboard;
  final bool obscure;
  final Widget? suffix;

  const _StyledInput({
    required this.controller,
    required this.hint,
    this.keyboard = TextInputType.text,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              obscureText: obscure,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _ink),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                    fontSize: 13,
                    color: _ink2,
                    fontWeight: FontWeight.w400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOGIN BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _LoginButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onTap;
  const _LoginButton({required this.loading, required this.onTap});

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.loading ? null : widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 54,
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.loading ? _darkPill.withOpacity(0.5) : _darkPill,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: widget.loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: _white, strokeWidth: 2.5),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('⚡', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MINI CHIP
// ─────────────────────────────────────────────────────────────────────────────
class _MiniChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  const _MiniChip(
      {required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _ink)),
        ],
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