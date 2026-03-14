import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../controller/auth_controller.dart';
import 'forgot_password_otp_screen.dart';

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
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final phoneController = TextEditingController();
  final authController  = AuthController();
  bool loading = false;

  Future<void> sendOtp() async {
    if (phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter phone number',
              style: TextStyle(color: _ink, fontWeight: FontWeight.w600)),
          backgroundColor: _peach,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => loading = true);
    try {
      await authController.forgotPassword(phoneController.text.trim());

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ForgotPasswordOtpScreen(phone: phoneController.text.trim()),
        ),
      );
    } catch (e) {
      debugPrint('Forgot password error: $e');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: _bg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Error',
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
  void dispose() {
    phoneController.dispose();
    super.dispose();
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
  final _ForgotPasswordScreenState s;
  const _MobileLayout(this.s);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ── Back button row ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _BackButton(),
              ],
            ),
          ),
          // ── Hero ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _HeroCard(),
          ),
          // ── Form ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: _FormSection(s),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DESKTOP LAYOUT
// ─────────────────────────────────────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  final _ForgotPasswordScreenState s;
  const _DesktopLayout(this.s);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left hero panel
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _HeroCard(tall: true),
          ),
        ),
        // Right form panel
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
                child: Row(children: [_BackButton()]),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 24),
                    child: _FormSection(s),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BACK BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: _white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_ios_new_rounded, size: 13, color: _ink),
            SizedBox(width: 6),
            Text('Back',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _ink)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO CARD — dark pill matching Admin Dashboard
// ─────────────────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final bool tall;
  const _HeroCard({this.tall = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tall ? double.infinity : 210,
      decoration: BoxDecoration(
        color: _darkPill,
        borderRadius: BorderRadius.circular(30),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // decorative circles
          Positioned(
            top: -40, right: -20,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _blush.withValues(alpha: 0.18)),
            ),
          ),
          Positioned(
            bottom: -30, right: 70,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _peach.withValues(alpha: 0.15)),
            ),
          ),
          Positioned(
            left: -20, bottom: 60,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _lavender.withValues(alpha: 0.12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _blush.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: _blush.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                            color: _blush, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      const Text('Password Reset',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _blush)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Reset\nPassword',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: _white,
                    height: 1.05,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter your phone number\nto receive an OTP.',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6A6A68),
                      height: 1.5,
                      fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Row(
                  children: [
                    _HeroPill(label: '📲 OTP Verify', color: _blush),
                    const SizedBox(width: 8),
                    _HeroPill(label: '🔑 New Pass', color: _peach),
                  ],
                ),
              ],
            ),
          ),
        ],
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
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FORM SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _FormSection extends StatelessWidget {
  final _ForgotPasswordScreenState s;
  const _FormSection(this.s);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Section label ────────────────────────────────────────
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Verify Phone',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                    letterSpacing: -0.5)),
            Text('Step 1 of 2 →',
                style: TextStyle(
                    fontSize: 12,
                    color: _ink2,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),

        // ── Info bento strip ─────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _MiniInfoTile(
                  emoji: '📲', label: 'OTP sent via SMS', color: _blush),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniInfoTile(
                  emoji: '⏱️', label: 'Valid 10 mins', color: _peach),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Phone bento field ────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _sky.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('📱', style: TextStyle(fontSize: 13)),
                  SizedBox(width: 6),
                  Text('Mobile Number',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _ink2)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: _white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: s.phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _ink),
                  decoration: const InputDecoration(
                    hintText: 'Enter 10-digit mobile number',
                    hintStyle: TextStyle(
                        fontSize: 13,
                        color: _ink2,
                        fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Send OTP button ──────────────────────────────────────
        _SendOtpButton(loading: s.loading, onTap: s.sendOtp),
        const SizedBox(height: 16),

        // ── Bottom chips ─────────────────────────────────────────
        Row(
          children: [
            Expanded(
                child:
                    _MiniChip(emoji: '🔒', label: 'Encrypted', color: _sage)),
            const SizedBox(width: 10),
            Expanded(
                child: _MiniChip(
                    emoji: '📡', label: 'Instant OTP', color: _sky)),
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
// MINI INFO TILE
// ─────────────────────────────────────────────────────────────────────────────
class _MiniInfoTile extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  const _MiniInfoTile(
      {required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _ink)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEND OTP BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _SendOtpButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onTap;
  const _SendOtpButton({required this.loading, required this.onTap});

  @override
  State<_SendOtpButton> createState() => _SendOtpButtonState();
}

class _SendOtpButtonState extends State<_SendOtpButton> {
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
        transform: Matrix4.identity()..scaleByVector3(vm.Vector3.all(_pressed ? 0.97 : 1.0)),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.loading ? _darkPill.withValues(alpha: 0.5) : _darkPill,
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
                  Text('📲', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Text(
                    'Send OTP',
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
        color: color.withValues(alpha: 0.35),
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
