import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../../../core/api/dashboard_service.dart';
import '../../../core/api/service_history_service.dart';
import '../../../core/models/dashboard.dart';
import '../../../core/services/purifier_model_cache.dart';
import '../../../core/services/installation_event_service.dart';
import '../../../core/ui/ui_kit.dart';
import '../../auth/services/auth_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOMER DASHBOARD SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  late Future<CustomerDashboard> _dashFuture;

  @override
  void initState() {
    super.initState();
    _dashFuture = _loadDashboard();
    InstallationEventService.installationCompletedNotifier
        .addListener(_onInstallationCompleted);
  }

  @override
  void dispose() {
    InstallationEventService.installationCompletedNotifier
        .removeListener(_onInstallationCompleted);
    super.dispose();
  }

  void _onInstallationCompleted() {
    debugPrint(
        '[CustomerDashboard] Installation event received, refreshing');
    setState(() => _dashFuture = _loadDashboard());
  }

  Future<CustomerDashboard> _loadDashboard() async {
    final token = await AuthService.getToken();
    debugPrint('CUSTOMER DASHBOARD TOKEN => $token');

    var dashboard = await DashboardService.fetchDashboard();

    try {
      final serviceHistory =
          await ServiceHistoryService.fetchServiceHistory();
      if (serviceHistory.isNotEmpty) {
        dashboard = CustomerDashboard(
          customerId: dashboard.customerId,
          purifierModel: dashboard.purifierModel,
          installDate: dashboard.installDate,
          nextServiceDate: dashboard.nextServiceDate,
          services: serviceHistory,
        );
      }
    } catch (e) {
      debugPrint('[CustomerDashboard] Service history fetch failed: $e');
    }

    if ((dashboard.nextServiceDate == null ||
            dashboard.nextServiceDate!.isEmpty) &&
        dashboard.installDate.isNotEmpty) {
      try {
        final modelId = int.tryParse(dashboard.purifierModel) ?? 0;
        if (modelId > 0) {
          final model = await PurifierModelCache().getModel(modelId);
          if (model != null) {
            final installDate = DateTime.parse(dashboard.installDate);
            final nextService =
                installDate.add(Duration(days: model.serviceIntervalDays));
            final formatted =
                '${nextService.year}-${nextService.month.toString().padLeft(2, '0')}-${nextService.day.toString().padLeft(2, '0')}';
            dashboard = CustomerDashboard(
              customerId: dashboard.customerId,
              purifierModel: dashboard.purifierModel,
              installDate: dashboard.installDate,
              nextServiceDate: formatted,
              services: dashboard.services,
            );
          }
        }
      } catch (e) {
        debugPrint(
            '[CustomerDashboard] Error calculating next service: $e');
      }
    }

    return dashboard;
  }

  Future<String> _getModelName(String modelIdStr) async {
    try {
      final modelId = int.tryParse(modelIdStr) ?? 0;
      if (modelId == 0) return modelIdStr;
      return await PurifierModelCache().getModelName(modelId);
    } catch (e) {
      return modelIdStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kInk),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: SpagCornerBadge()),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async =>
              setState(() => _dashFuture = _loadDashboard()),
          child: FutureBuilder<CustomerDashboard>(
            future: _dashFuture,
            builder: (context, snapshot) {
              // ── Loading ──────────────────────────────────────────
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: kInk),
                );
              }

              // ── Error ────────────────────────────────────────────
              if (snapshot.hasError) {
                final err = snapshot.error.toString();

                if (err.contains('Installation pending')) {
                  return _InstallationPendingState();
                }
                if (err.contains('Installation not found')) {
                  return _NoInstallationState();
                }

                return ErrorStateCard(
                  title: 'Failed to load dashboard',
                  message:
                      'You need to be logged in to view your dashboard. Please log in and try again.',
                  onRetry: () =>
                      setState(() => _dashFuture = _loadDashboard()),
                  onLogin: () =>
                      Navigator.of(context).pushNamed('/login'),
                );
              }

              // ── Success ──────────────────────────────────────────
              final data = snapshot.data!;
              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  // 1. Hero card
                  _HeroCard(data: data, getModelName: _getModelName),
                  const SizedBox(height: 14),

                  // 2. Stats bento row
                  _StatsBentoRow(data: data),
                  const SizedBox(height: 14),

                  // 3. Mini info cards
                  _MiniInfoRow(data: data),
                  const SizedBox(height: 20),

                  // 4. Service history
                  const _SectionTitle('Service History'),
                  const SizedBox(height: 12),
                  _ServiceHistoryList(services: data.services),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. HERO CARD
// ─────────────────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final CustomerDashboard data;
  final Future<String> Function(String) getModelName;
  const _HeroCard({required this.data, required this.getModelName});

  @override
  Widget build(BuildContext context) {
    final total = data.services.length;
    final completed =
        data.services.where((s) => s.status == 'COMPLETED').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: kDarkPill,
          borderRadius: BorderRadius.circular(30),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // decorative circles
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kLavender.withValues(alpha: 0.18),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              right: 60,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kMint.withValues(alpha: 0.15),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // status pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: kMint.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(100),
                      border:
                          Border.all(color: kMint.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: kMint, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        // model name from API
                        FutureBuilder<String>(
                          future: getModelName(data.purifierModel),
                          builder: (context, snap) {
                            final name =
                                snap.data ?? data.purifierModel;
                            return Text(
                              name,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: kMint,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'My\nPurifier',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: kWhite,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),

                  const Spacer(),

                  Row(
                    children: [
                      HeroPill(
                        label:
                            'Next: ${data.nextServiceDate ?? 'TBD'}',
                        color: kPeach,
                      ),
                      const SizedBox(width: 8),
                      HeroPill(
                        label: '$completed/$total Done',
                        color: kLavender,
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// 2. STATS BENTO ROW
// ─────────────────────────────────────────────────────────────────────────────
class _StatsBentoRow extends StatelessWidget {
  final CustomerDashboard data;
  const _StatsBentoRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.services.length;
    final completed =
        data.services.where((s) => s.status == 'COMPLETED').length;
    final pending = total - completed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // big left card — total
          Expanded(
            flex: 5,
            child: BentoCard(
              color: kLavender,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Services',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: kInk2)),
                  const SizedBox(height: 6),
                  Text(
                    '$total',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: kInk,
                      height: 1,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SmallBadge(
                    label: '$completed completed',
                    textColor: const Color(0xFF4A3C8C),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // right column — completed + pending
          Expanded(
            flex: 4,
            child: Column(
              children: [
                BentoCard(
                  color: kMint,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Completed',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: kInk2)),
                      const SizedBox(height: 6),
                      Text('$completed',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: kInk,
                            height: 1,
                            letterSpacing: -2,
                          )),
                      const SizedBox(height: 8),
                      _SmallBadge(
                        label:
                            total > 0 ? '${((completed / total) * 100).toInt()}%' : '0%',
                        textColor: const Color(0xFF1A6B48),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                BentoCard(
                  color: kBlush,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pending',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: kInk2)),
                      const SizedBox(height: 6),
                      Text('$pending',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: kInk,
                            height: 1,
                            letterSpacing: -2,
                          )),
                      const SizedBox(height: 8),
                      _SmallBadge(
                        label: pending > 0
                            ? '$pending in progress'
                            : 'All clear',
                        textColor: const Color(0xFF8B3047),
                      ),
                    ],
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
// 3. MINI INFO ROW
// ─────────────────────────────────────────────────────────────────────────────
class _MiniInfoRow extends StatelessWidget {
  final CustomerDashboard data;
  const _MiniInfoRow({required this.data});

  String _formatDate(String raw) {
    if (raw.isEmpty) return '—';
    try {
      final d = DateTime.parse(raw);
      return '${d.year}-${d.month.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.length > 7 ? raw.substring(0, 7) : raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = data.services.length;
    final completed =
        data.services.where((s) => s.status == 'COMPLETED').length;
    final resolvedPct =
        total > 0 ? ((completed / total) * 100).toInt() : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _MiniCard(
              icon: '📅',
              value: _formatDate(data.installDate),
              label: 'Install Date',
              color: kSage,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniCard(
              icon: '🔧',
              value: data.nextServiceDate != null &&
                      data.nextServiceDate!.length >= 7
                  ? data.nextServiceDate!.substring(5, 10)
                  : 'TBD',
              label: 'Next Service',
              color: kSky,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniCard(
              icon: '✅',
              value: '$resolvedPct%',
              label: 'Resolved',
              color: kPeach,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;
  const _MiniCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

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
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: kInk,
                  height: 1)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: kInk2)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. SERVICE HISTORY LIST
// ─────────────────────────────────────────────────────────────────────────────
class _ServiceHistoryList extends StatelessWidget {
  final List<dynamic> services;
  const _ServiceHistoryList({required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: kWhite.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            children: [
              Text('📭',
                  style: TextStyle(fontSize: 36)),
              SizedBox(height: 12),
              Text('No service history yet',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kInk)),
              SizedBox(height: 4),
              Text('Your service records will appear here',
                  style: TextStyle(fontSize: 12, color: kInk2),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: services.map((s) {
          final isDone = s.status == 'COMPLETED';
          return _ServiceItem(
            serviceNumber: s.serviceNumber.toString(),
            date: s.serviceDate,
            status: s.status,
            isDone: isDone,
          );
        }).toList(),
      ),
    );
  }
}

class _ServiceItem extends StatefulWidget {
  final String serviceNumber;
  final String date;
  final String status;
  final bool isDone;
  const _ServiceItem({
    required this.serviceNumber,
    required this.date,
    required this.status,
    required this.isDone,
  });

  @override
  State<_ServiceItem> createState() => _ServiceItemState();
}

class _ServiceItemState extends State<_ServiceItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.isDone ? kMint : kPeach;
    final badgeTextColor = widget.isDone
        ? const Color(0xFF0F6E56)
        : const Color(0xFF854F0B);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 10),
        transform: Matrix4.identity()
          ..scaleByVector3(
              vm.Vector3.all(_pressed ? 0.98 : 1.0)),
        transformAlignment: Alignment.center,
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: kWhite.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: Colors.black.withValues(alpha: 0.05), width: 0.5),
        ),
        child: Row(
          children: [
            // icon tile
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: dotColor.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  widget.isDone ? '✓' : '⏳',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service #${widget.serviceNumber}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kInk,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(widget.date,
                      style: const TextStyle(
                          fontSize: 10, color: kInk2)),
                ],
              ),
            ),

            // status badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: dotColor.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                widget.status,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: badgeTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SPECIAL ERROR STATES
// ─────────────────────────────────────────────────────────────────────────────
class _InstallationPendingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: Colors.black.withValues(alpha: 0.07),
                width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kPeach.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text('⏳', style: TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Installation Pending',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kInk)),
              const SizedBox(height: 6),
              const Text(
                'Your installation is pending.\nPlease wait for the technician.',
                style: TextStyle(fontSize: 12, color: kInk2, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoInstallationState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: Colors.black.withValues(alpha: 0.07),
                width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kSky.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text('📭', style: TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('No Installation Found',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kInk)),
              const SizedBox(height: 6),
              const Text(
                "You don't have a registered installation yet.\nPlease request one or contact support.",
                style: TextStyle(fontSize: 12, color: kInk2, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS (local to this file)
// ─────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: kInk,
          letterSpacing: -0.5,
        ),
      ),
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
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kWhite.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: textColor),
      ),
    );
  }
}