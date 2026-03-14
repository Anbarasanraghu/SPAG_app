import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../services/service_logs_service.dart';
import 'customer_detail_screen.dart';

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

class TechnicianActivityLogsScreen extends StatefulWidget {
  final int? technicianId;
  const TechnicianActivityLogsScreen({super.key, this.technicianId});

  @override
  State<TechnicianActivityLogsScreen> createState() =>
      _TechnicianActivityLogsScreenState();
}

class _TechnicianActivityLogsScreenState
    extends State<TechnicianActivityLogsScreen> {
  bool loading = true;
  List<dynamic> logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  // ── ALL LOGIC UNCHANGED ───────────────────────────────────────────────────
  Future<void> _loadLogs() async {
    try {
      final data = widget.technicianId == null
          ? await ServiceLogsService.getAllTechnicianActivityLogs()
          : await ServiceLogsService.getTechnicianActivityLogs(
              widget.technicianId!);
      setState(() {
        logs = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading activity logs: $e')),
        );
      }
    }
  }

  Color _actionColor(String action) {
    switch (action) {
      case 'COMPLETED':
        return const Color(0xFF10B981);
      case 'ASSIGNED':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFFF59E0B);
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
        child: loading

            // ── LOADING ───────────────────────────────────────────────────
            ? const Center(child: CircularProgressIndicator())

            : logs.isEmpty

                // ── EMPTY ─────────────────────────────────────────────────
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: _kSage.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.run_circle_outlined,
                              size: 40, color: _kInk2),
                        ),
                        const SizedBox(height: 14),
                        const Text('No activity logs found',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _kInk)),
                        const SizedBox(height: 4),
                        const Text('Activity logs will appear here',
                            style:
                                TextStyle(fontSize: 11, color: _kInk2)),
                      ],
                    ),
                  )

                // ── LIST ──────────────────────────────────────────────────
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [

                      // ── Hero Card ───────────────────────────────────────
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Mint badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: _kMint.withValues(alpha: 0.18),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(
                                            color:
                                                _kMint.withValues(alpha: 0.4)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6, height: 6,
                                            decoration:
                                                const BoxDecoration(
                                                    color: _kMint,
                                                    shape:
                                                        BoxShape.circle),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                              '${logs.length} Activities',
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
                                      'Activity\nLogs',
                                      style: TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                        color: _kWhite,
                                        height: 1.1,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(children: [
                                      _HeroPill(
                                          label:
                                              '${logs.length} Records',
                                          color: _kPeach),
                                      const SizedBox(width: 8),
                                      _HeroPill(
                                          label: widget.technicianId !=
                                                  null
                                              ? 'Tech #${widget.technicianId}'
                                              : 'All Technicians',
                                          color: _kLavender),
                                    ]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Section Title ───────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Recent Activity',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: _kInk,
                                    letterSpacing: -0.5)),
                            Text('${logs.length} total',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: _kInk2,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Log Cards ───────────────────────────────────────
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: List.generate(logs.length, (index) {
                            final log = logs[index];
                            final serviceId = log['service_id'] ??
                                log['serviceId'] ??
                                log['id'];
                            final customerId = log['customer_id'] ??
                                log['customerId'] ??
                                log['customer_id'];
                            final action =
                                log['action']?.toString() ?? '';
                            final color = _cardColor(index);

                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 12),
                              child: _LogCard(
                                log: log,
                                action: action,
                                serviceId: serviceId,
                                color: color,
                                actionColor: _actionColor(action),
                                onTap: customerId != null
                                    ? () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                CustomerDetailScreen(
                                                    customerId:
                                                        customerId),
                                          ),
                                        )
                                    : null,
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOG CARD — pastel bento with press animation
// ─────────────────────────────────────────────────────────────────────────────
class _LogCard extends StatefulWidget {
  final dynamic log;
  final String action;
  final dynamic serviceId;
  final Color color;
  final Color actionColor;
  final VoidCallback? onTap;

  const _LogCard({
    required this.log,
    required this.action,
    required this.serviceId,
    required this.color,
    required this.actionColor,
    this.onTap,
  });

  @override
  State<_LogCard> createState() => _LogCardState();
}

class _LogCardState extends State<_LogCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final log = widget.log;
    final when = log['logged_at'] ?? log['created_at'] ?? '-';

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Action icon box
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _kWhite.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.run_circle,
                  color: widget.actionColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.action.isEmpty ? '-' : widget.action,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _kInk,
                        letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 6),
                  // Service + When row
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: _kWhite.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Svc: ${widget.serviceId ?? '-'}',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _kInk2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: _kWhite.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        when.toString().length > 16
                            ? when.toString().substring(0, 16)
                            : when.toString(),
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _kInk2),
                      ),
                    ),
                  ]),
                ],
              ),
            ),

            // Arrow chip (only if tappable)
            if (widget.onTap != null)
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: _kWhite.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_forward_ios,
                    size: 12, color: _kInk),
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
