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
    switch (action.toUpperCase()) {
      case 'INSTALLATION_COMPLETED':
        return const Color(0xFF10B981);
      case 'SERVICE_COMPLETED':
        return const Color(0xFF10B981);
      case 'ASSIGNED':
        return const Color(0xFF3B82F6);
      case 'IN_PROGRESS':
      case 'SERVICE_STARTED':
        return const Color(0xFF8B5CF6);
      case 'PENDING':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
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
                            final logId = log['id'];
                            final action =
                                log['action']?.toString() ?? '';
                            final createdAt = log['created_at'] ?? '-';
                            final technician = log['technician'] as Map<String, dynamic>?;
                            final techName = technician?['name'] ?? 'Unknown';
                            final techPhone = technician?['phone'] ?? '-';
                            final color = _cardColor(index);

                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 12),
                              child: _LogCard(
                                log: log,
                                action: action,
                                logId: logId,
                                technicianName: techName,
                                technicianPhone: techPhone,
                                createdAt: createdAt,
                                color: color,
                                actionColor: _actionColor(action),
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
  final dynamic logId;
  final String technicianName;
  final String technicianPhone;
  final dynamic createdAt;
  final Color color;
  final Color actionColor;

  const _LogCard({
    required this.log,
    required this.action,
    required this.logId,
    required this.technicianName,
    required this.technicianPhone,
    required this.createdAt,
    required this.color,
    required this.actionColor,
  });

  @override
  State<_LogCard> createState() => _LogCardState();
}

class _LogCardState extends State<_LogCard> {
  bool _pressed = false;

  String _formatAction(String action) {
    return action
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null || dateStr == '-') return '-';
    try {
      final date = DateTime.parse(dateStr.toString());
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr.toString().substring(0, 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Action + Status indicator
            Row(
              children: [
                // Action icon box
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: _kWhite.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.check_circle_outline,
                      color: widget.actionColor, size: 22),
                ),
                const SizedBox(width: 14),
                // Action text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatAction(widget.action),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _kInk,
                            letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.actionColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ID: ${widget.logId}',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: widget.actionColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Technician info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _kWhite.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: widget.actionColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(Icons.person,
                          size: 16, color: widget.actionColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.technicianName,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _kInk),
                        ),
                        Text(
                          widget.technicianPhone,
                          style: const TextStyle(
                              fontSize: 10,
                              color: _kInk2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Timestamp
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _kInk2.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time,
                      size: 12, color: _kInk2),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(widget.createdAt),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _kInk2),
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
