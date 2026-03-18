// ui_kit.dart
// Shared UI components and color palette for the SPAG app

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

// ─── BENTO CARD ────────────────────────────────────────────────────────────
class BentoCard extends StatelessWidget {
  final Color color;
  final Widget child;
  const BentoCard({required this.color, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(26),
      ),
      child: child,
    );
  }
}

// ─── PALETTE ────────────────────────────────────────────────────────────────
const Color kBg       = Color(0xFFF5F4F0);
const Color kWhite    = Color(0xFFFFFFFF);
const Color kInk      = Color(0xFF111110);
const Color kInk2     = Color(0xFF8A8880);
const Color kDarkPill = Color(0xFF1A1A18);
const Color kLavender = Color(0xFFD5CCFF);
const Color kMint     = Color(0xFFBDF0D8);
const Color kBlush    = Color(0xFFF5C8D4);
const Color kSky      = Color(0xFFBFE0F5);
const Color kPeach    = Color(0xFFF8DBBF);
const Color kSage     = Color(0xFFC8DFC0);

// ─── HERO PILL ──────────────────────────────────────────────────────────────
class HeroPill extends StatelessWidget {
  final String label;
  final Color color;
  const HeroPill({required this.label, required this.color, super.key});

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

// ─── MINI CHIP ──────────────────────────────────────────────────────────────
class MiniChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  const MiniChip({required this.emoji, required this.label, required this.color, super.key});

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
                  color: kInk)),
        ],
      ),
    );
  }
}

// ─── BENTO FIELD ────────────────────────────────────────────────────────────
class BentoField extends StatelessWidget {
  final Color accentColor;
  final String emoji;
  final String label;
  final Widget child;
  const BentoField({
    required this.accentColor,
    required this.emoji,
    required this.label,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.3),
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
                      color: kInk2)),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ─── STYLED INPUT ───────────────────────────────────────────────────────────
class StyledInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboard;
  final bool obscure;
  final Widget? suffix;

  const StyledInput({
    required this.controller,
    required this.hint,
    this.keyboard = TextInputType.text,
    this.obscure = false,
    this.suffix,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite.withValues(alpha: 0.75),
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
                  color: kInk),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                    fontSize: 13,
                    color: kInk2,
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

// ─── PILL BUTTON ────────────────────────────────────────────────────────────
class PillButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onTap;
  final String label;
  final String? emoji;
  const PillButton({required this.loading, required this.onTap, required this.label, this.emoji, super.key});

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
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
          color: widget.loading
              ? kDarkPill.withValues(alpha: 0.5)
              : kDarkPill,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: widget.loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: kWhite, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.emoji != null) ...[
                    Text(widget.emoji!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: kWhite,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── SPAG CORNER BADGE (Compact) ───────────────────────────────────────
//
// A small badge suitable for placing in AppBar actions or a top-right corner.
// Use in AppBar actions wherever you want the brand identity visible.
//
// Usage: const SpagCornerBadge()
//
class SpagCornerBadge extends StatelessWidget {
  final bool darkSurface;
  const SpagCornerBadge({this.darkSurface = false, super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = darkSurface
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.72);
    final borderColor = darkSurface
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.10);
    final logoBg = darkSurface
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFFFFFFF);
    final logoBorderColor = darkSurface
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);
    final nameColor = darkSurface ? const Color(0xFFFFFFFF) : const Color(0xFF111110);
    final subColor  = darkSurface
        ? Colors.white.withValues(alpha: 0.45)
        : const Color(0xFF8A8880);

    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: logoBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: logoBorderColor, width: 0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    'assets/spag-logo.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SPAG Service',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: nameColor,
                        height: 1.15)),
                const SizedBox(height: 2),
                Text('Official App',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: subColor,
                        height: 1.15)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ERROR STATE CARD ──────────────────────────────────────────────────────
class ErrorStateCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onLogin;

  const ErrorStateCard({
    required this.title,
    required this.message,
    required this.onRetry,
    this.onLogin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // ── Icon tile ──────────────────────────────────────────
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4ED),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD85A30).withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFD85A30),
                size: 26,
              ),
            ),

            const SizedBox(height: 14),

            // ── Title ─────────────────────────────────────────────
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kInk,
              ),
            ),

            const SizedBox(height: 6),

            // ── Message ───────────────────────────────────────────
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: kInk2,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 20),

            // ── Divider ───────────────────────────────────────────
            Container(
              height: 0.5,
              color: Colors.black.withValues(alpha: 0.07),
              margin: const EdgeInsets.only(bottom: 16),
            ),

            // ── Login button (primary) ─────────────────────────────
            if (onLogin != null) ...[
              SizedBox(
                width: double.infinity,
                height: 44,
                child: GestureDetector(
                  onTap: onLogin,
                  child: Container(
                    decoration: BoxDecoration(
                      color: kDarkPill,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kWhite,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // ── Retry button (secondary) ───────────────────────────
            SizedBox(
              width: double.infinity,
              height: 44,
              child: GestureDetector(
                onTap: onRetry,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.15),
                      width: 0.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.refresh_rounded,
                          size: 15, color: kInk),
                      SizedBox(width: 6),
                      Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: kInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// Add more shared widgets as needed.