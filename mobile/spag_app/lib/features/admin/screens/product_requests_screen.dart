import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../services/admin_service.dart';
import '../models/product_request_model.dart';
import 'assign_product_request_screen.dart';

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

const _cardColors = [
  Color(0xFFB4A0FF),
  Color(0xFF82DCB4),
  Color(0xFF8CC8F0),
  Color(0xFFFFB48C),
  Color(0xFFFFB4BE),
  Color(0xFF96C8A0),
];

class ProductRequestsScreen extends StatefulWidget {
  const ProductRequestsScreen({super.key});

  @override
  State<ProductRequestsScreen> createState() => _ProductRequestsScreenState();
}

class _ProductRequestsScreenState extends State<ProductRequestsScreen> {
  List<ProductRequest> _requests = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final data = await AdminService.getProductRequests();
      setState(() {
        _requests = data.map((e) => ProductRequest.fromJson(e)).toList();
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
              Text('Failed to load requests',
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

  List<ProductRequest> get _filteredRequests => _requests.where((r) =>
      r.id.toString().contains(_searchQuery) ||
      r.status.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      r.phone.contains(_searchQuery)).toList();
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'APPROVED':
        return const Color(0xFF10B981);
      case 'PENDING':
        return const Color(0xFFF59E0B);
      case 'ASSIGNED':
        return const Color(0xFF3B82F6);
      case 'REJECTED':
      case 'CANCELLED':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getStatusBgColor(String status) =>
      _getStatusColor(status).withValues(alpha: 0.15);

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'APPROVED':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.pending_actions;
      case 'ASSIGNED':
        return Icons.assignment_turned_in;
      case 'REJECTED':
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Color _cardColor(int i) => _cardColors[i % _cardColors.length];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,

      // ── AppBar — plain back arrow (dashboard style) ───────────────────────
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kInk),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _requests.isEmpty
                ? _buildEmpty()
                : _buildList(),
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
            child: const Icon(Icons.inventory_2_outlined,
                size: 40, color: _kInk2),
          ),
          const SizedBox(height: 14),
          const Text('No product requests',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _kInk)),
          const SizedBox(height: 4),
          const Text('Product requests will appear here',
              style: TextStyle(fontSize: 11, color: _kInk2)),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [

          // ── Hero Card ────────────────────────────────────────
          Padding(
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
                            border: Border.all(
                                color: _kMint.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6, height: 6,
                                decoration: const BoxDecoration(
                                    color: _kMint,
                                    shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text('${_requests.length} Requests',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _kMint)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Product\nRequests',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: _kWhite,
                            height: 1.1,
                            letterSpacing: -1,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            _HeroPill(
                                label: '${_requests.length} Total',
                                color: _kPeach),
                            const SizedBox(width: 8),
                            const _HeroPill(
                                label: 'Review & Assign',
                                color: _kLavender),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Section Title with Search ──────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('All Requests',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _kInk,
                        letterSpacing: -0.5)),
                const Spacer(),
                SizedBox(
                  width: 180,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search, color: _kInk2, size: 18),
                      filled: true,
                      fillColor: _kWhite.withValues(alpha: 0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    style: const TextStyle(color: _kInk, fontSize: 12),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Request Cards ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: List.generate(_filteredRequests.length, (index) {
                final r = _filteredRequests[index];
                final color = _cardColor(index);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RequestCard(
                    request: r,
                    color: color,
                    statusColor: _getStatusColor(r.status),
                    statusBgColor: _getStatusBgColor(r.status),
                    statusIcon: _getStatusIcon(r.status),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssignProductRequestScreen(
                          requestId: r.id,
                        ),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REQUEST CARD — pastel bento style with press animation
// ─────────────────────────────────────────────────────────────────────────────
class _RequestCard extends StatefulWidget {
  final ProductRequest request;
  final Color color;
  final Color statusColor;
  final Color statusBgColor;
  final IconData statusIcon;
  final VoidCallback onTap;

  const _RequestCard({
    required this.request,
    required this.color,
    required this.statusColor,
    required this.statusBgColor,
    required this.statusIcon,
    required this.onTap,
  });

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.request;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        transform: Matrix4.identity()..scaleByVector3(vm.Vector3.all(_pressed ? 0.97 : 1.0)),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [

            // Icon box
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: _kWhite.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  color: _kInk, size: 22),
            ),
            const SizedBox(width: 14),

            // Request info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Request #${r.id}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _kInk,
                          letterSpacing: -0.3)),
                  const SizedBox(height: 6),
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.statusBgColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.statusIcon,
                            size: 11, color: widget.statusColor),
                        const SizedBox(width: 5),
                        Text(r.status,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: widget.statusColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Phone
                  Row(children: [
                    Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        color: _kWhite.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                          child: Text('📞',
                              style: TextStyle(fontSize: 8))),
                    ),
                    const SizedBox(width: 6),
                    Text(r.phone,
                        style: const TextStyle(
                            fontSize: 11, color: _kInk2)),
                  ]),
                ],
              ),
            ),

            // Arrow chip — white translucent
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: _kWhite.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_ios,
                  size: 13, color: _kInk),
            ),
          ],
        ),
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
