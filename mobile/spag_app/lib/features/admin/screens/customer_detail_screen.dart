import 'package:flutter/material.dart';
import '../services/admin_customer_service.dart';
import '../models/admin_customer.dart';

// ─── COLOUR TOKENS — matches AdminDashboard ui_kit ───────────────────────────
const _kBg       = Color(0xFFF5F5F0);
const _kDarkPill = Color(0xFF1E1E2E);
const _kInk      = Color(0xFF1A1A1A);
const _kInk2     = Color(0xFF666666);
const _kWhite    = Color(0xFFFFFFFF);
const _kMint     = Color(0xFF82DCB4);
const _kLavender = Color(0xFFB4A0FF);
const _kPeach    = Color(0xFFFFB48C);
const _kBlush    = Color(0xFFFFB4BE);
const _kSage     = Color(0xFF96C8A0);
const _kSky      = Color(0xFF8CC8F0);

class CustomerDetailScreen extends StatefulWidget {
  final int customerId;
  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  bool _loading = true;
  AdminCustomer? _customer;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    try {
      final data = await AdminCustomerService.fetchCustomer(widget.customerId);
      if (!mounted) return;
      setState(() {
        _customer = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load customer: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,

      // ── AppBar — plain back arrow, no title (hero carries heading) ─────────
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kInk),
          onPressed: () {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          },
        ),
      ),

      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _customer == null
                ? _buildEmpty()
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      // ── 1. Hero Card ───────────────────────────────────
                      _buildHeroCard(),
                      const SizedBox(height: 14),

                      // ── 2. Mini Stats Row ──────────────────────────────
                      _buildMiniStatsRow(),
                      const SizedBox(height: 20),

                      // ── 3. Section Title ───────────────────────────────
                      _SectionTitle('Contact Info'),
                      const SizedBox(height: 12),

                      // ── 4. Info Cards ──────────────────────────────────
                      _buildInfoCards(),

                      const SizedBox(height: 28),
                    ],
                  ),
      ),
    );
  }

  // ── HERO CARD — dark pill identical to dashboard ──────────────────────────
  Widget _buildHeroCard() {
    final c = _customer!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          color: _kDarkPill,
          borderRadius: BorderRadius.circular(30),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -30, right: -20,
              child: Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kLavender.withValues(alpha: 0.18),
                ),
              ),
            ),
            Positioned(
              bottom: -20, right: 60,
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kMint.withValues(alpha: 0.15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(26),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left — avatar + name + ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mint badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: _kMint.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(100),
                            border:
                                Border.all(color: _kMint.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6, height: 6,
                                decoration: const BoxDecoration(
                                    color: _kMint, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text('ID #${c.customerId}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _kMint)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Name
                        Text(
                          c.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: _kWhite,
                            height: 1.1,
                            letterSpacing: -1,
                          ),
                        ),
                        const Spacer(),
                        // Pills
                        Row(
                          children: [
                            _HeroPill(label: 'Customer', color: _kPeach),
                            const SizedBox(width: 8),
                            _HeroPill(label: 'Active', color: _kMint),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right — avatar circle
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: _kWhite.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                          color: _kWhite.withValues(alpha: 0.25), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        _initials(c.name),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: _kWhite,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── MINI STATS ROW ────────────────────────────────────────────────────────
  Widget _buildMiniStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
              child: _MiniCard(
                  label: 'Orders', value: '5', icon: '📦', color: _kSage)),
          const SizedBox(width: 10),
          Expanded(
              child: _MiniCard(
                  label: 'Services', value: '3', icon: '⚙️', color: _kSky)),
          const SizedBox(width: 10),
          Expanded(
              child: _MiniCard(
                  label: 'Resolved', value: '100%', icon: '✅',
                  color: _kPeach)),
        ],
      ),
    );
  }

  // ── INFO CARDS — bento style ──────────────────────────────────────────────
  Widget _buildInfoCards() {
    final c = _customer!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Phone bento
          _BentoInfoCard(
            color: _kLavender,
            icon: '📞',
            label: 'Phone Number',
            value: c.phone,
          ),
          const SizedBox(height: 12),
          // Address bento
          _BentoInfoCard(
            color: _kSky,
            icon: '📍',
            label: 'Address',
            value: c.address,
          ),
          const SizedBox(height: 12),
          // Customer ID bento
          _BentoInfoCard(
            color: _kMint,
            icon: '🪪',
            label: 'Customer ID',
            value: '#${c.customerId}',
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _kLavender.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child:
                const Icon(Icons.person_off_outlined, size: 40, color: _kInk2),
          ),
          const SizedBox(height: 14),
          const Text('No customer data',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, color: _kInk)),
          const SizedBox(height: 4),
          const Text('Customer record not found',
              style: TextStyle(fontSize: 11, color: _kInk2)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO PILL
// ─────────────────────────────────────────────────────────────────────────────
class _HeroPill extends StatelessWidget {
  final String label;
  final Color color;
  const _HeroPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MINI CARD — same as MiniInfoCard in dashboard
// ─────────────────────────────────────────────────────────────────────────────
class _MiniCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;
  const _MiniCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _kInk,
                  height: 1)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w600, color: _kInk2)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BENTO INFO CARD — pastel card for contact details
// ─────────────────────────────────────────────────────────────────────────────
class _BentoInfoCard extends StatelessWidget {
  final Color color;
  final String icon;
  final String label;
  final String value;
  const _BentoInfoCard(
      {required this.color,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Icon box
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _kWhite.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 14),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _kInk2)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _kInk,
                        letterSpacing: -0.3)),
              ],
            ),
          ),
          // Arrow chip
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: _kWhite.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: _kInk),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION TITLE — mirrors dashboard SectionTitle
// ─────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _kInk,
                  letterSpacing: -0.5)),
          const Text('View all →',
              style: TextStyle(
                  fontSize: 12,
                  color: _kInk2,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
