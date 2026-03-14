import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../models/admin_customer.dart';
import '../services/admin_customer_service.dart';
import 'customer_detail_screen.dart';

// ─── COLOUR TOKENS — matches AdminDashboard ui_kit ───────────────────────────
const _kBg        = Color(0xFFF5F5F0); // warm off-white (kBg)
const _kDarkPill  = Color(0xFF1E1E2E); // hero card bg (kDarkPill)
const _kInk       = Color(0xFF1A1A1A); // primary text (kInk)
const _kInk2      = Color(0xFF666666); // secondary text (kInk2)
const _kWhite     = Color(0xFFFFFFFF);
const _kMint      = Color(0xFF82DCB4); // badge / hero dot
const _kLavender  = Color(0xFFB4A0FF);
const _kMintCard  = Color(0xFF82DCB4);
const _kBlush     = Color(0xFFFFB4BE);
const _kPeach     = Color(0xFFFFB48C);
const _kSage      = Color(0xFF96C8A0);
const _kSky       = Color(0xFF8CC8F0);

// Six pastel card colours cycling across customer cards (matches action grid)
const _cardColors = [
  Color(0xFFB4A0FF), // lavender
  Color(0xFF82DCB4), // mint
  Color(0xFF8CC8F0), // sky
  Color(0xFFFFB48C), // peach
  Color(0xFFFFB4BE), // blush
  Color(0xFF96C8A0), // sage
];

// ─────────────────────────────────────────────────────────────────────────────
class AllCustomersScreen extends StatefulWidget {
  const AllCustomersScreen({super.key});

  @override
  State<AllCustomersScreen> createState() => _AllCustomersScreenState();
}

class _AllCustomersScreenState extends State<AllCustomersScreen> {
  bool _loading = true;
  List<AdminCustomer> _customers = [];
  String _searchQuery = '';

  List<AdminCustomer> get _filteredCustomers => _customers.where((c) =>
      c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      c.phone.contains(_searchQuery) ||
      c.address.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final data = await AdminCustomerService.fetchCustomers();
      setState(() {
        _customers = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.error_outline, color: Colors.white, size: 14),
              SizedBox(width: 8),
              Text('Failed to load customers',
                  style: TextStyle(fontSize: 12)),
            ]),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Color _cardColor(int i) => _cardColors[i % _cardColors.length];

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  // ── Pull-to-refresh ───────────────────────────────────────────────────────
  Future<void> _refresh() async {
    setState(() => _loading = true);
    await _loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,

      // ── AppBar — plain back arrow, no title (hero card carries the heading)
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
            : _customers.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: [
                        // ── 1. Hero Card ───────────────────────────────────
                        _HeroCard(total: _customers.length),
                        const SizedBox(height: 14),

                        // ── 2. Bento Stats Row ─────────────────────────────
                        _StatsRow(total: _customers.length),
                        const SizedBox(height: 14),

                        // ── 3. Mini Stats Row ──────────────────────────────
                        _MiniStatsRow(total: _customers.length),
                        const SizedBox(height: 20),

                        // ── 4. Section Title ───────────────────────────────
                        _SectionTitle('Customer List'),
                        const SizedBox(height: 12),

                        // ── 5. Search Bar ───────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search customers...',
                              prefixIcon: const Icon(Icons.search, color: _kInk2),
                              filled: true,
                              fillColor: _kWhite.withValues(alpha: 0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            style: const TextStyle(color: _kInk, fontSize: 14),
                            onChanged: (value) => setState(() => _searchQuery = value),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── 6. Customer Cards ──────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: List.generate(_filteredCustomers.length, (i) {
                              final c = _filteredCustomers[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _CustomerCard(
                                  customer: c,
                                  color: _cardColor(i),
                                  initials: _initials(c.name),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CustomerDetailScreen(
                                          customerId: c.customerId),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
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
            child: const Icon(Icons.people_outline_rounded,
                size: 40, color: _kInk2),
          ),
          const SizedBox(height: 14),
          const Text('No customers found',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, color: _kInk)),
          const SizedBox(height: 4),
          const Text('Customer list is empty',
              style: TextStyle(fontSize: 11, color: _kInk2)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO CARD  — identical dark pill to AdminDashboard
// ─────────────────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final int total;
  const _HeroCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 200,
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
            // Content
            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _kMint.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: _kMint.withValues(alpha: 0.4)),
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
                        Text('$total Customers',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _kMint)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Title
                  const Text(
                    'All\nCustomers',
                    style: TextStyle(
                      fontSize: 34,
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
                      _HeroPill(label: '$total Total', color: _kPeach),
                      const SizedBox(width: 8),
                      _HeroPill(label: '4 Active', color: _kLavender),
                      const SizedBox(width: 8),
                      _HeroPill(label: '3 Areas', color: _kMintCard),
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
// BENTO STATS ROW — mirrors dashboard StatsRow
// ─────────────────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int total;
  const _StatsRow({required this.total});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: isMobile
          ? Column(
              children: [
                // Total customers
                _BentoCard(
                  color: _kLavender,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Customers',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _kInk2)),
                      const SizedBox(height: 6),
                      Text('$total',
                          style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: _kInk,
                              height: 1,
                              letterSpacing: -2)),
                      const SizedBox(height: 10),
                      _SmallBadge(
                          label: '+2 this month ↑',
                          textColor: const Color(0xFF4A3C8C)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Active and Areas in row
                Row(
                  children: [
                    Expanded(
                      child: _BentoCard(
                        color: _kMintCard,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Active',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _kInk2)),
                            const SizedBox(height: 6),
                            const Text('4',
                                style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    color: _kInk,
                                    height: 1,
                                    letterSpacing: -2)),
                            const SizedBox(height: 8),
                            const _SmallBadge(
                                label: 'online',
                                textColor: Color(0xFF1A6B48)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BentoCard(
                        color: _kBlush,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Areas',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _kInk2)),
                            const SizedBox(height: 6),
                            const Text('3',
                                style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    color: _kInk,
                                    height: 1,
                                    letterSpacing: -2)),
                            const SizedBox(height: 8),
                            const _SmallBadge(
                                label: 'zones',
                                textColor: Color(0xFF8B3047)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Large left bento — total customers
                Expanded(
                  flex: 5,
                  child: _BentoCard(
                    color: _kLavender,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Customers',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _kInk2)),
                        const SizedBox(height: 6),
                        Text('$total',
                            style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: _kInk,
                                height: 1,
                                letterSpacing: -2)),
                        const SizedBox(height: 10),
                        _SmallBadge(
                            label: '+2 this month ↑',
                            textColor: const Color(0xFF4A3C8C)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Right column — two small bentos side by side
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Expanded(
                        child: _BentoCard(
                          color: _kMintCard,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Active',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _kInk2)),
                              const SizedBox(height: 6),
                              const Text('4',
                                  style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      color: _kInk,
                                      height: 1,
                                      letterSpacing: -2)),
                              const SizedBox(height: 8),
                              const _SmallBadge(
                                  label: 'online',
                                  textColor: Color(0xFF1A6B48)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BentoCard(
                          color: _kBlush,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Areas',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _kInk2)),
                              const SizedBox(height: 6),
                              const Text('3',
                                  style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      color: _kInk,
                                      height: 1,
                                      letterSpacing: -2)),
                              const SizedBox(height: 8),
                              const _SmallBadge(
                                  label: 'zones',
                                  textColor: Color(0xFF8B3047)),
                            ],
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
// MINI STATS ROW — mirrors dashboard MiniStatsRow
// ─────────────────────────────────────────────────────────────────────────────
class _MiniStatsRow extends StatelessWidget {
  final int total;
  const _MiniStatsRow({required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
              child: _MiniCard(
                  label: 'Orders', value: '12', icon: '📦', color: _kSage)),
          const SizedBox(width: 10),
          Expanded(
              child: _MiniCard(
                  label: 'Services', value: '8', icon: '⚙️', color: _kSky)),
          const SizedBox(width: 10),
          Expanded(
              child: _MiniCard(
                  label: 'Resolved', value: '92%', icon: '✅', color: _kPeach)),
        ],
      ),
    );
  }
}

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

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOMER CARD — pastel bento style matching action cards
// ─────────────────────────────────────────────────────────────────────────────
class _CustomerCard extends StatefulWidget {
  final AdminCustomer customer;
  final Color color;
  final String initials;
  final VoidCallback onTap;
  const _CustomerCard(
      {required this.customer,
      required this.color,
      required this.initials,
      required this.onTap});

  @override
  State<_CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<_CustomerCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.all(16),
        transform: Matrix4.identity()..scaleByVector3(vm.Vector3.all(_pressed ? 0.97 : 1.0)),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: _pressed ? 0.65 : 0.4),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            // Avatar — rounded square, white translucent bg
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _kWhite.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(widget.initials,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _kInk)),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.customer.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _kInk,
                          letterSpacing: -0.3)),
                  const SizedBox(height: 5),
                  // Phone
                  Row(children: [
                    Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        color: _kWhite.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                          child: Text('📞',
                              style: TextStyle(fontSize: 9))),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(widget.customer.phone,
                          style: const TextStyle(
                              fontSize: 11, color: _kInk2)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  // Address
                  Row(children: [
                    Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        color: _kWhite.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                          child: Text('📍',
                              style: TextStyle(fontSize: 9))),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(widget.customer.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: _kInk2)),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Arrow chip — same as dashboard action cards
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: _kWhite.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: _kInk),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _BentoCard extends StatelessWidget {
  final Color color;
  final Widget child;
  const _BentoCard({required this.color, required this.child});

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

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color textColor;
  const _SmallBadge({required this.label, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kWhite.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor)),
    );
  }
}
