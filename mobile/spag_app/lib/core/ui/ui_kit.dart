// ui_kit.dart
// Shared UI components and color palette for the SPAG app

import 'package:flutter/material.dart';

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
        color: color.withOpacity(0.45),
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
        color: kWhite.withOpacity(0.75),
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

// ─── LOGIN BUTTON ───────────────────────────────────────────────────────────
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
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.loading
              ? kDarkPill.withOpacity(0.5)
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

// ─── SPAG FOOTER LOGO ──────────────────────────────────────────────────────
class SpagFooterLogo extends StatelessWidget {
  const SpagFooterLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: kDarkPill,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                'SPAG Service',
                style: const TextStyle(
                  color: kWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            top: -15,
            right: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: kWhite,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/spag-logo.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add more shared widgets as needed.
