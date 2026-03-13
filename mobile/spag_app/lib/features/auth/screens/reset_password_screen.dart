import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/auth_controller.dart';
import 'login_screen.dart';

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
class ResetPasswordScreen extends StatefulWidget {
  final String phone;
  const ResetPasswordScreen({super.key, required this.phone});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final newPasswordController     = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final authController            = AuthController();
  bool loading        = false;
  bool obscureNew     = true;
  bool obscureConfirm = true;

  Future<void> resetPassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match',
              style: TextStyle(color: _ink, fontWeight: FontWeight.w600)),
          backgroundColor: _blush,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password must be at least 6 characters',
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
      await authController.resetPassword(
          widget.phone, newPasswordController.text);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: _bg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('🎉 Success!',
              style: TextStyle(
                  fontWeight: FontWeight.w800, color: _ink, fontSize: 18)),
          content: const Text(
              'Your password has been reset.\nPlease login with your new password.',
              style: TextStyle(color: _ink2, fontSize: 13, height: 1.5)),
          actions: [
            TextButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: _darkPill,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text('Login Now',
                    style: TextStyle(
                        color: _white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
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
    newPasswordController.dispose();
    confirmPasswordController.dispose();
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
  final _ResetPasswordScreenState s;
  const _MobileLayout(this.s);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [_BackBtn()]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: const _HeroCard(),
          ),
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
  final _ResetPasswordScreenState s;
  const _DesktopLayout(this.s);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: const _HeroCard(tall: true),
          ),
        ),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
                child: Row(children: [_BackBtn()]),
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
class _BackBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: _white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_ios_new_rounded, size: 13, color: _ink),
            SizedBox(width: 6),
            Text('Back',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: _ink)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO CARD — sage/mint theme for "new password" feel
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
          Positioned(
            top: -40, right: -20,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _sage.withOpacity(0.2)),
            ),
          ),
          Positioned(
            bottom: -30, right: 70,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _mint.withOpacity(0.15)),
            ),
          ),
          Positioned(
            left: -20, bottom: 60,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _sky.withOpacity(0.12)),
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
                    color: _sage.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: _sage.withOpacity(0.45)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                            color: _sage, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      const Text('New Password',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _sage)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Create New\nPassword',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: _white,
                    height: 1.05,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter a strong password\nto secure your account.',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6A6A68),
                      height: 1.5,
                      fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Row(
                  children: [
                    _HeroPill(label: '🔐 Strong Pass', color: _sage),
                    const SizedBox(width: 8),
                    _HeroPill(label: '✅ Final Step', color: _mint),
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
// FORM SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _FormSection extends StatelessWidget {
  final _ResetPasswordScreenState s;
  const _FormSection(this.s);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header ──────────────────────────────────────────────
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Set Password',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                    letterSpacing: -0.5)),
            Text('Final step →',
                style: TextStyle(
                    fontSize: 12,
                    color: _ink2,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),

        // ── Strength tips strip ──────────────────────────────────
        Row(
          children: [
            Expanded(
                child: _InfoTile(
                    emoji: '🔢', label: 'Min 6 chars', color: _sky)),
            const SizedBox(width: 10),
            Expanded(
                child: _InfoTile(
                    emoji: '🔐', label: 'Use symbols', color: _peach)),
          ],
        ),
        const SizedBox(height: 14),

        // ── New password bento field ─────────────────────────────
        _PasswordBentoField(
          accentColor: _sage,
          emoji: '🔒',
          label: 'New Password',
          hint: 'Enter new password',
          controller: s.newPasswordController,
          obscure: s.obscureNew,
          onToggle: () => s.setState(() => s.obscureNew = !s.obscureNew),
        ),
        const SizedBox(height: 12),

        // ── Confirm password bento field ─────────────────────────
        _PasswordBentoField(
          accentColor: _lavender,
          emoji: '🔑',
          label: 'Confirm Password',
          hint: 'Re-enter your password',
          controller: s.confirmPasswordController,
          obscure: s.obscureConfirm,
          onToggle: () =>
              s.setState(() => s.obscureConfirm = !s.obscureConfirm),
        ),
        const SizedBox(height: 20),

        // ── Reset button ─────────────────────────────────────────
        _ResetButton(loading: s.loading, onTap: s.resetPassword),
        const SizedBox(height: 16),

        // ── Bottom chips ─────────────────────────────────────────
        Row(
          children: [
            Expanded(
                child: _MiniChip(
                    emoji: '🛡️', label: 'Encrypted', color: _sage)),
            const SizedBox(width: 10),
            Expanded(
                child: _MiniChip(
                    emoji: '🔄', label: 'Instant', color: _sky)),
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
// INFO TILE
// ─────────────────────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  const _InfoTile(
      {required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 7),
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
// PASSWORD BENTO FIELD
// ─────────────────────────────────────────────────────────────────────────────
class _PasswordBentoField extends StatelessWidget {
  final Color accentColor;
  final String emoji;
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordBentoField({
    required this.accentColor,
    required this.emoji,
    required this.label,
    required this.hint,
    required this.controller,
    required this.obscure,
    required this.onToggle,
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
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _ink2)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
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
                GestureDetector(
                  onTap: onToggle,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Text(
                      obscure ? '👁️' : '🙈',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESET BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _ResetButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onTap;
  const _ResetButton({required this.loading, required this.onTap});

  @override
  State<_ResetButton> createState() => _ResetButtonState();
}

class _ResetButtonState extends State<_ResetButton> {
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
                  Text('🔐', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Text(
                    'Reset Password',
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