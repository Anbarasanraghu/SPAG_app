import 'package:flutter/material.dart';
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

class ProductRequestsScreen extends StatelessWidget {
  const ProductRequestsScreen({super.key});

  // ── STATUS HELPERS — logic completely unchanged ───────────────────────────
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
      _getStatusColor(status).withOpacity(0.15);

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
        child: FutureBuilder(
          future: AdminService.getProductRequests(),
          builder: (context, snapshot) {

            // ── LOADING ───────────────────────────────────────────────
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ── ERROR ─────────────────────────────────────────────────
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: _kBlush.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.error_outline,
                            size: 40, color: _kInk2),
                      ),
                      const SizedBox(height: 14),
                      const Text('Error loading requests',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _kInk)),
                      const SizedBox(height: 4),
                      const Text('Please try again later',
                          style: TextStyle(fontSize: 11, color: _kInk2)),
                    ],
                  ),
                ),
              );
            }

            final List requests = snapshot.data as List;

            // ── EMPTY ─────────────────────────────────────────────────
            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: _kLavender.withOpacity(0.3),
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

            // ── LIST ──────────────────────────────────────────────────
            return ListView(
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
                              color: _kLavender.withOpacity(0.18),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -20, right: 60,
                          child: Container(
                            width: 90, height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _kMint.withOpacity(0.15),
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
                                  color: _kMint.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      color: _kMint.withOpacity(0.4)),
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
                                    Text('${requests.length} Requests',
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
                                      label: '${requests.length} Total',
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

                // ── Section Title ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('All Requests',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _kInk,
                              letterSpacing: -0.5)),
                      Text('${requests.length} total',
                          style: const TextStyle(
                              fontSize: 12,
                              color: _kInk2,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Request Cards ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: List.generate(requests.length, (index) {
                      final r = ProductRequest.fromJson(requests[index]);
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
            );
          },
        ),
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
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.38),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [

            // Icon box
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: _kWhite.withOpacity(0.5),
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
                ],
              ),
            ),

            // Arrow chip — white translucent
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: _kWhite.withOpacity(0.6),
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
        color: color.withOpacity(0.22),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}