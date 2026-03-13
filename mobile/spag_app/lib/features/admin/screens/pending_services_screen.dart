import 'package:flutter/material.dart';
import '../models/pending_service.dart';
import '../services/pending_service_service.dart';

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

// Six pastel card colours cycling across service cards
const _cardColors = [
  Color(0xFFB4A0FF), // lavender
  Color(0xFF82DCB4), // mint
  Color(0xFF8CC8F0), // sky
  Color(0xFFFFB48C), // peach
  Color(0xFFFFB4BE), // blush
  Color(0xFF96C8A0), // sage
];

class PendingServicesScreen extends StatefulWidget {
  const PendingServicesScreen({super.key});

  @override
  State<PendingServicesScreen> createState() => _PendingServicesScreenState();
}

class _PendingServicesScreenState extends State<PendingServicesScreen> {
  bool loading = true;
  List<PendingService> services = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await PendingServiceService.fetchPendingServices();
      setState(() {
        services = data;
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  // ── ASSIGN DIALOG — logic completely unchanged ────────────────────────────
  Future<void> _showAssignDialog(int serviceId) async {
    final technicianIdController = TextEditingController();
    bool isAssigning = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: _kBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            title: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _kLavender.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person_add, color: _kInk, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Assign Technician',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _kInk)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _kPeach.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('Service #$serviceId',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _kInk2)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: technicianIdController,
                  keyboardType: TextInputType.number,
                  enabled: !isAssigning,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kInk),
                  decoration: InputDecoration(
                    hintText: 'Enter technician ID',
                    hintStyle:
                        const TextStyle(fontSize: 12, color: _kInk2),
                    filled: true,
                    fillColor: _kLavender.withOpacity(0.18),
                    prefixIcon: const Icon(Icons.badge_outlined,
                        color: _kInk2, size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: _kLavender.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: _kLavender, width: 1.5),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: _kLavender.withOpacity(0.1)),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isAssigning
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: const Text('Cancel',
                    style: TextStyle(color: _kInk2)),
              ),
              GestureDetector(
                onTap: isAssigning
                    ? null
                    : () async {
                        final techId =
                            technicianIdController.text.trim();

                        if (techId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.white),
                                SizedBox(width: 12),
                                Text('Please enter technician ID'),
                              ]),
                              backgroundColor:
                                  const Color(0xFFF59E0B),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                            ),
                          );
                          return;
                        }

                        setDialogState(() => isAssigning = true);

                        try {
                          await PendingServiceService.assignTechnician(
                            serviceId: serviceId,
                            technicianId: int.parse(techId),
                          );

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(children: [
                                Icon(Icons.check_circle,
                                    color: Colors.white),
                                SizedBox(width: 12),
                                Text('Technician assigned successfully ✅'),
                              ]),
                              backgroundColor:
                                  const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                            ),
                          );

                          Navigator.pop(dialogContext);
                          _load();
                        } catch (e) {
                          if (!context.mounted) return;
                          final message = e
                              .toString()
                              .replaceFirst('Exception: ', '');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text('Failed: $message')),
                              ]),
                              backgroundColor:
                                  const Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                            ),
                          );
                        } finally {
                          setDialogState(() => isAssigning = false);
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isAssigning
                        ? _kInk2.withOpacity(0.2)
                        : _kDarkPill,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: isAssigning
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(
                              color: _kWhite, strokeWidth: 2))
                      : const Text('Assign',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _kWhite)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── STATUS HELPERS — logic unchanged ─────────────────────────────────────
  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case "ASSIGNED":
        return const Color(0xFF3B82F6);
      case "IN_PROGRESS":
      case "IN PROGRESS":
        return const Color(0xFFF59E0B);
      case "COMPLETED":
        return const Color(0xFF10B981);
      case "PENDING":
      default:
        return const Color(0xFFF59E0B);
    }
  }

  Color _statusBgColor(String status) {
    switch (status.toUpperCase()) {
      case "ASSIGNED":
        return const Color(0xFF3B82F6).withOpacity(0.15);
      case "IN_PROGRESS":
      case "IN PROGRESS":
        return const Color(0xFFF59E0B).withOpacity(0.15);
      case "COMPLETED":
        return const Color(0xFF10B981).withOpacity(0.15);
      case "PENDING":
      default:
        return const Color(0xFFF59E0B).withOpacity(0.15);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case "ASSIGNED":
        return Icons.assignment_turned_in;
      case "IN_PROGRESS":
      case "IN PROGRESS":
        return Icons.hourglass_bottom;
      case "COMPLETED":
        return Icons.check_circle;
      case "PENDING":
      default:
        return Icons.pending_actions;
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
          onPressed: () {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          },
        ),
      ),

      body: SafeArea(
        top: false,
        child: loading

            // ── LOADING ───────────────────────────────────────────────────
            ? const Center(child: CircularProgressIndicator())

            : RefreshIndicator(
                onRefresh: () async => _load(),
                child: services.isEmpty

                    // ── EMPTY ─────────────────────────────────────────────
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: _kPeach.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                  Icons.pending_actions_outlined,
                                  size: 40,
                                  color: _kInk2),
                            ),
                            const SizedBox(height: 14),
                            const Text('No pending services',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: _kInk)),
                            const SizedBox(height: 4),
                            const Text('All services are up to date',
                                style: TextStyle(
                                    fontSize: 11, color: _kInk2)),
                          ],
                        ),
                      )

                    // ── LIST ──────────────────────────────────────────────
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        children: [

                          // ── Hero Card ─────────────────────────────────
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Mint badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: _kMint.withOpacity(0.18),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            border: Border.all(
                                                color:
                                                    _kMint.withOpacity(0.4)),
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
                                              Text(
                                                  '${services.length} Pending',
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: _kMint)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        const Text(
                                          'Pending\nServices',
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
                                                label:
                                                    '${services.length} Services',
                                                color: _kPeach),
                                            const SizedBox(width: 8),
                                            _HeroPill(
                                                label: 'Review & Manage',
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

                          // ── Section Title ──────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Service Requests',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: _kInk,
                                        letterSpacing: -0.5)),
                                Text('${services.length} total',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: _kInk2,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ── Service Cards ──────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: List.generate(services.length, (i) {
                                final s = services[i];
                                final color = _cardColor(i);
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 12),
                                  child: _ServiceCard(
                                    service: s,
                                    color: color,
                                    statusColor: _statusColor(s.status),
                                    statusBgColor: _statusBgColor(s.status),
                                    statusIcon: _statusIcon(s.status),
                                    onAssign: () =>
                                        _showAssignDialog(s.serviceId),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICE CARD — pastel bento style
// ─────────────────────────────────────────────────────────────────────────────
class _ServiceCard extends StatefulWidget {
  final PendingService service;
  final Color color;
  final Color statusColor;
  final Color statusBgColor;
  final IconData statusIcon;
  final VoidCallback onAssign;

  const _ServiceCard({
    required this.service,
    required this.color,
    required this.statusColor,
    required this.statusBgColor,
    required this.statusIcon,
    required this.onAssign,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.service;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        transform: Matrix4.identity()..scale(_pressed ? 0.98 : 1.0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.38),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header Row ───────────────────────────────────────────────
            Row(
              children: [
                // Avatar box
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(Icons.person_outline,
                        color: _kInk, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + service number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.customerName,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _kInk,
                              letterSpacing: -0.3)),
                      const SizedBox(height: 3),
                      Text('Service #${s.serviceNumber}',
                          style: const TextStyle(
                              fontSize: 11, color: _kInk2)),
                    ],
                  ),
                ),
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: widget.statusBgColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.statusIcon,
                          size: 11, color: widget.statusColor),
                      const SizedBox(width: 4),
                      Text(s.status,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: widget.statusColor)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Service Date bento ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF).withOpacity(0.45),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: _kSage.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_today_outlined,
                        size: 14, color: _kInk),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Service Date',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _kInk2)),
                      const SizedBox(height: 2),
                      Text(s.serviceDate,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _kInk)),
                    ],
                  ),
                ],
              ),
            ),

            // ── Technician or Assign button ──────────────────────────────
            if (s.technicianName != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: _kSky.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.engineering,
                          size: 14, color: _kInk),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Assigned Technician',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: _kInk2)),
                        const SizedBox(height: 2),
                        Text(s.technicianName!,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _kInk)),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 14),
              GestureDetector(
                onTap: widget.onAssign,
                child: Container(
                  width: double.infinity,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _kDarkPill,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_outlined,
                          color: _kWhite, size: 17),
                      SizedBox(width: 8),
                      Text('Assign Technician',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _kWhite,
                              letterSpacing: -0.2)),
                    ],
                  ),
                ),
              ),
            ],
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