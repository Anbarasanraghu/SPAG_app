import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../controller/auth_controller.dart';
import 'reset_password_screen.dart';

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
class ForgotPasswordOtpScreen extends StatefulWidget {
  final String phone;
  const ForgotPasswordOtpScreen({super.key, required this.phone});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final otpController  = TextEditingController();
  final authController = AuthController();
  bool loading = false;
  int resendCountdown = 0;
  int otpExpiry = 300;
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
    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          resendCountdown--;
          if (resendCountdown <= 0) resendTimer.cancel();
        });
      }
    });
  }

  void startExpiryCountdown() {
    otpExpiry = 300;
    expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          otpExpiry--;
          if (otpExpiry <= 0) {
            expiryTimer.cancel();
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: _bg,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                title: const Text('OTP Expired',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _ink,
                        fontSize: 18)),
                content: const Text(
                    'The OTP has expired. Please request a new one.',
                    style: TextStyle(color: _ink2, fontSize: 13)),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
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
          }
        });
      }
    });
  }

  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter OTP',
              style:
                  TextStyle(color: _ink, fontWeight: FontWeight.w600)),
          backgroundColor: _peach,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => loading = true);
    try {
      await authController.verifyResetOtp(
          widget.phone, otpController.text.trim());

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

  Future<void> resendOtp() async {
    setState(() => loading = true);
    try {
      await authController.forgotPassword(widget.phone);
      startResendCountdown();
      startExpiryCountdown();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('OTP sent successfully',
              style:
                  TextStyle(color: _ink, fontWeight: FontWeight.w600)),
          backgroundColor: _mint,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      debugPrint('Resend OTP error: $e');
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
    otpController.dispose();
    resendTimer.cancel();
    expiryTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final minutes    = otpExpiry ~/ 60;
    final seconds    = otpExpiry % 60;
    final expiryText = '$minutes:${seconds.toString().padLeft(2, '0')}';
    final isExpiring = otpExpiry < 60;
    final isWide     = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: isWide
            ? _DesktopLayout(
                s: this,
                expiryText: expiryText,
                isExpiring: isExpiring,
              )
            : _MobileLayout(
                s: this,
                expiryText: expiryText,
                isExpiring: isExpiring,
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE LAYOUT
// ─────────────────────────────────────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final _ForgotPasswordOtpScreenState s;
  final String expiryText;
  final bool isExpiring;
  const _MobileLayout(
      {required this.s,
      required this.expiryText,
      required this.isExpiring});

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
            child: _HeroCard(phone: s.widget.phone),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: _FormSection(
                s: s, expiryText: expiryText, isExpiring: isExpiring),
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
  final _ForgotPasswordOtpScreenState s;
  final String expiryText;
  final bool isExpiring;
  const _DesktopLayout(
      {required this.s,
      required this.expiryText,
      required this.isExpiring});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _HeroCard(phone: s.widget.phone, tall: true),
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
                    child: _FormSection(
                        s: s,
                        expiryText: expiryText,
                        isExpiring: isExpiring),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
// HERO CARD
// ─────────────────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final String phone;
  final bool tall;
  const _HeroCard({required this.phone, this.tall = false});

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
                  color: _mint.withOpacity(0.18)),
            ),
          ),
          Positioned(
            bottom: -30, right: 70,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _lavender.withOpacity(0.15)),
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
                    color: _mint.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: _mint.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                            color: _mint, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      const Text('OTP Verification',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _mint)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Verify\nYour OTP',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: _white,
                    height: 1.05,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Code sent to\n$phone',
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6A6A68),
                      height: 1.5,
                      fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Row(
                  children: [
                    _HeroPill(label: '🔢 6-digit Code', color: _mint),
                    const SizedBox(width: 8),
                    _HeroPill(label: '⏱️ 5 min limit', color: _lavender),
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
  final _ForgotPasswordOtpScreenState s;
  final String expiryText;
  final bool isExpiring;
  const _FormSection(
      {required this.s,
      required this.expiryText,
      required this.isExpiring});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header ──────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Enter OTP',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                    letterSpacing: -0.5)),
            Text('Step 2 of 2 →',
                style: const TextStyle(
                    fontSize: 12,
                    color: _ink2,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),

        // ── Timer + phone strip ──────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                emoji: '📱',
                label: s.widget.phone,
                color: _sky,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InfoTile(
                emoji: '⏱️',
                label: 'Expires $expiryText',
                color: isExpiring ? _blush : _peach,
                urgent: isExpiring,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── OTP bento field ──────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _lavender.withOpacity(0.3),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('🔢', style: TextStyle(fontSize: 13)),
                  SizedBox(width: 6),
                  Text('OTP Code',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _ink2)),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: _white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: s.otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                    letterSpacing: 10,
                  ),
                  decoration: InputDecoration(
                    hintText: '------',
                    hintStyle: TextStyle(
                      fontSize: 22,
                      letterSpacing: 8,
                      color: _ink.withOpacity(0.15),
                      fontWeight: FontWeight.w900,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // progress bar
              _ExpiryBar(otpExpiry: s.otpExpiry, isExpiring: isExpiring),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Verify button ────────────────────────────────────────
        _VerifyButton(
          loading: s.loading,
          disabled: s.otpExpiry <= 0,
          onTap: s.verifyOtp,
        ),
        const SizedBox(height: 14),

        // ── Resend row ───────────────────────────────────────────
        _ResendRow(
          countdown: s.resendCountdown,
          loading: s.loading,
          onResend: s.resendOtp,
        ),
        const SizedBox(height: 16),

        // ── Bottom chips ─────────────────────────────────────────
        Row(
          children: [
            Expanded(
                child: _MiniChip(
                    emoji: '🔒', label: 'Encrypted', color: _sage)),
            const SizedBox(width: 10),
            Expanded(
                child: _MiniChip(
                    emoji: '✅', label: 'Verified', color: _mint)),
            const SizedBox(width: 10),
            Expanded(
                child: _MiniChip(
                    emoji: '💧', label: 'PureCare', color: _sky)),
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
  final bool urgent;
  const _InfoTile(
      {required this.emoji,
      required this.label,
      required this.color,
      this.urgent = false});

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
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: urgent ? const Color(0xFF8B3047) : _ink,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPIRY PROGRESS BAR
// ─────────────────────────────────────────────────────────────────────────────
class _ExpiryBar extends StatelessWidget {
  final int otpExpiry;
  final bool isExpiring;
  const _ExpiryBar({required this.otpExpiry, required this.isExpiring});

  @override
  Widget build(BuildContext context) {
    final progress = (otpExpiry / 300).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Time remaining',
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _ink2)),
            Text('${(progress * 100).toInt()}%',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isExpiring
                        ? const Color(0xFF8B3047)
                        : _ink2)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: _white.withOpacity(0.5),
            valueColor: AlwaysStoppedAnimation<Color>(
              isExpiring ? _blush : _mint,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VERIFY BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _VerifyButton extends StatefulWidget {
  final bool loading;
  final bool disabled;
  final VoidCallback onTap;
  const _VerifyButton(
      {required this.loading,
      required this.disabled,
      required this.onTap});

  @override
  State<_VerifyButton> createState() => _VerifyButtonState();
}

class _VerifyButtonState extends State<_VerifyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isInactive = widget.loading || widget.disabled;
    return GestureDetector(
      onTap: isInactive ? null : widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 54,
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: isInactive ? _darkPill.withOpacity(0.4) : _darkPill,
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
                  Text('✅', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Text(
                    'Verify OTP',
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
// RESEND ROW
// ─────────────────────────────────────────────────────────────────────────────
class _ResendRow extends StatelessWidget {
  final int countdown;
  final bool loading;
  final VoidCallback onResend;
  const _ResendRow(
      {required this.countdown,
      required this.loading,
      required this.onResend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _sage.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📩', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          countdown > 0
              ? Text(
                  'Resend in ${countdown}s',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _ink2),
                )
              : GestureDetector(
                  onTap: loading ? null : onResend,
                  child: Text(
                    'Resend OTP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: loading ? _ink2 : _ink,
                      decoration: TextDecoration.underline,
                      decorationColor: _ink,
                    ),
                  ),
                ),
        ],
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