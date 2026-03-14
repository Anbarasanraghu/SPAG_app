import 'package:flutter/material.dart';
import '../models/service_detail.dart';
import '../services/service_detail_service.dart';
import '../services/technician_service_log_service.dart';
import '../models/service_status_log.dart';
import '../models/technician_activity_log.dart';

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

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool loading = true;
  ServiceDetail? detail;
  List<ServiceStatusLog> statusLogs = [];
  List<TechnicianActivityLog> techLogs = [];

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  // ── ALL LOGIC UNCHANGED ───────────────────────────────────────────────────
  Future<void> _loadDetail() async {
    try {
      final data = await ServiceDetailService.fetchServiceDetail(widget.serviceId);
      setState(() {
        detail = data;
        loading = false;
      });

      try {
        final fetchedStatusLogs = await TechnicianServiceLogService
            .fetchStatusLogsForService(widget.serviceId);
        final List<TechnicianActivityLog> fetchedTechLogs = [];
        if (detail != null && detail!.technicianId != null) {
          final tlogs = await TechnicianServiceLogService
              .fetchTechnicianActivityLogs(detail!.technicianId!);
          fetchedTechLogs.addAll(tlogs);
        }
        setState(() {
          statusLogs = fetchedStatusLogs;
          techLogs = fetchedTechLogs;
        });
      } catch (e) {
        debugPrint('Error fetching related logs: $e');
      }
    } catch (e) {
      setState(() => loading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text("Failed to load service details"),
            ]),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  bool get canMarkCompleted =>
      detail != null && detail!.status == "ASSIGNED";

  Color _getStatusColor(String status) {
    switch (status) {
      case "COMPLETED":
        return const Color(0xFF10B981);
      case "ASSIGNED":
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case "COMPLETED":
        return Icons.check_circle;
      case "ASSIGNED":
        return Icons.assignment_turned_in;
      default:
        return Icons.schedule;
    }
  }

  // ── BENTO SECTION CARD ────────────────────────────────────────────────────
  Widget _bentoSection(String title, IconData icon, Color accent,
      List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _kWhite.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _kInk, size: 18),
            ),
            const SizedBox(width: 10),
            Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                    letterSpacing: -0.3)),
          ]),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  // ── BENTO INFO ROW ────────────────────────────────────────────────────────
  Widget _bentoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: _kWhite.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 13, color: _kInk2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _kInk2)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _kInk)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,

      // ── AppBar — plain back arrow ─────────────────────────────────────────
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

            : detail == null

                // ── EMPTY ─────────────────────────────────────────────────
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: _kLavender.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.info_outline,
                              size: 40, color: _kInk2),
                        ),
                        const SizedBox(height: 14),
                        const Text('No details found',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _kInk)),
                        const SizedBox(height: 4),
                        const Text('Service details are not available',
                            style:
                                TextStyle(fontSize: 11, color: _kInk2)),
                      ],
                    ),
                  )

                // ── CONTENT ───────────────────────────────────────────────
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
                                    // Status badge
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
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
                                          Text(detail!.status,
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: _kMint)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Service\n#${detail!.serviceNumber}',
                                      style: const TextStyle(
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
                                              'ID #${detail!.serviceId}',
                                          color: _kPeach),
                                      const SizedBox(width: 8),
                                      _HeroPill(
                                          label: detail!.serviceDate,
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

                      // ── Sections ────────────────────────────────────────
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Service Info
                            _bentoSection(
                              'Service Information',
                              Icons.info_outline,
                              _kLavender,
                              [
                                _bentoRow('Service ID',
                                    detail!.serviceId.toString(),
                                    Icons.confirmation_number_outlined),
                                _bentoRow('Service Date',
                                    detail!.serviceDate,
                                    Icons.calendar_today_outlined),
                                _bentoRow('Service Number',
                                    detail!.serviceNumber.toString(),
                                    Icons.numbers),
                              ],
                            ),

                            // Customer Info
                            _bentoSection(
                              'Customer Information',
                              Icons.person_outline,
                              _kSky,
                              [
                                _bentoRow('Customer ID',
                                    detail!.customerId.toString(),
                                    Icons.badge_outlined),
                                _bentoRow('Name', detail!.customerName,
                                    Icons.account_circle_outlined),
                                _bentoRow('Phone', detail!.customerPhone,
                                    Icons.phone_outlined),
                                _bentoRow('Address',
                                    detail!.customerAddress,
                                    Icons.location_on_outlined),
                              ],
                            ),

                            // Product Info
                            _bentoSection(
                              'Product Information',
                              Icons.inventory_2_outlined,
                              _kPeach,
                              [
                                _bentoRow('Installation ID',
                                    detail!.installationId.toString(),
                                    Icons.settings),
                                _bentoRow('Model', detail!.productModel,
                                    Icons.devices_outlined),
                              ],
                            ),

                            // Technician Info
                            _bentoSection(
                              'Technician Information',
                              Icons.engineering_outlined,
                              _kMint,
                              [
                                _bentoRow(
                                    'Technician',
                                    detail!.technicianName ??
                                        'Not Assigned',
                                    Icons.person_outline),
                                _bentoRow(
                                    'Phone',
                                    detail!.technicianPhone ?? '-',
                                    Icons.phone_outlined),
                              ],
                            ),

                            // ── Mark Completed Button ──────────────────
                            if (canMarkCompleted) ...[
                              GestureDetector(
                                onTap: () async {
                                  await TechnicianServiceLogService
                                      .updateServiceStatus(
                                    serviceId: detail!.serviceId,
                                    status: "COMPLETED",
                                  );
                                  _loadDetail();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: const Row(children: [
                                          Icon(Icons.check_circle,
                                              color: Colors.white),
                                          SizedBox(width: 12),
                                          Text(
                                              'Service marked as completed'),
                                        ]),
                                        backgroundColor:
                                            const Color(0xFF10B981),
                                        behavior:
                                            SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: _kDarkPill,
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                          Icons.check_circle_outline,
                                          color: _kMint,
                                          size: 20),
                                      SizedBox(width: 10),
                                      Text('Mark Service Completed',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: _kWhite,
                                              letterSpacing: -0.3)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],

                            // ── Status Change History ──────────────────
                            _bentoSection(
                              'Status Change History',
                              Icons.history,
                              _kSage,
                              statusLogs.isEmpty
                                  ? [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Text(
                                            'No status changes recorded.',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: _kInk2)),
                                      )
                                    ]
                                  : statusLogs.map((log) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 10),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: _kWhite
                                                .withValues(alpha: 0.45),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Text(
                                                      '${log.oldStatus ?? '-'} → ${log.newStatus}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight
                                                                  .w700,
                                                          fontSize: 12,
                                                          color: _kInk),
                                                    ),
                                                    const SizedBox(
                                                        height: 3),
                                                    Text(
                                                        'At: ${log.changedAt}',
                                                        style:
                                                            const TextStyle(
                                                                fontSize:
                                                                    10,
                                                                color:
                                                                    _kInk2)),
                                                  ],
                                                ),
                                              ),
                                              if (log.changedBy != null)
                                                Container(
                                                  padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: _kLavender
                                                        .withValues(alpha: 0.3),
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(8),
                                                  ),
                                                  child: Text(
                                                      'By: ${log.changedBy}',
                                                      style:
                                                          const TextStyle(
                                                              fontSize:
                                                                  10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color:
                                                                  _kInk)),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                            ),

                            // ── Technician Activity Logs ───────────────
                            if (techLogs.isNotEmpty)
                              _bentoSection(
                                'Technician Activity',
                                Icons.engineering_outlined,
                                _kBlush,
                                techLogs.map((t) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color:
                                            _kWhite.withValues(alpha: 0.45),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Text(t.action,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight
                                                                .w700,
                                                        fontSize: 12,
                                                        color: _kInk)),
                                                const SizedBox(height: 3),
                                                Text(
                                                    'At: ${t.createdAt}',
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        color: _kInk2)),
                                              ],
                                            ),
                                          ),
                                          if (t.serviceId != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _kMint
                                                    .withValues(alpha: 0.3),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8),
                                              ),
                                              child: Text(
                                                  'Svc: ${t.serviceId}',
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: _kInk)),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                            const SizedBox(height: 8),
                          ],
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
