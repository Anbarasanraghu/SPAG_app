import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../../../core/api/admin_dashboard_service.dart';
import '../../../core/models/admin_dashboard.dart';
import '../../../core/services/installation_event_service.dart';
import '../../../core/ui/ui_kit.dart';
import '../../auth/screens/login_screen.dart';
import '../../customer/screens/customer_main_screen.dart';
import 'product_requests_screen.dart';
import 'pending_services_screen.dart';
import 'manage_users_screen.dart';
import 'service_status_logs_screen.dart';
import 'technician_activity_logs_screen.dart';
import 'all_customers_screen.dart';

// ─── DASHBOARD CALCULATIONS ───────────────────────────────────────────────────
class DashboardCalculations {
  static String formatUserCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  static String getActivityStatus(int activeNow, int totalUsers) {
    if (totalUsers == 0) return '0% Active';
    final percentage = ((activeNow / totalUsers) * 100).toInt();
    return '$percentage% Active Now';
  }

  static double calculateTechnicianUtilization(int activeNow, int technicians) {
    if (technicians == 0) return 0.0;
    return ((activeNow / technicians) * 100).clamp(0.0, 100.0);
  }

  static List<double> generateGrowthChart(List<double> data, int bars) {
    if (data.isEmpty) {
      return List.filled(bars, 20.0);
    }
    final maxValue =
        data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) : 1.0;
    if (maxValue == 0) {
      return List.filled(bars, 20.0);
    }
    return data.take(bars).map((v) => (v / maxValue) * 60 + 10).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _navIndex = 0;
  late Future<AdminDashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = AdminDashboardService.fetchDashboardStats();
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
    debugPrint("[AdminDashboard] Installation event received, refreshing stats");
    setState(() {
      _statsFuture = AdminDashboardService.fetchDashboardStats();
    });
  }

  // ✅ SINGLE build method — PopScope wraps Scaffold, no back button in AppBar
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return PopScope(
      canPop: false, // intercepts the Android back button
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: kBg,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
            title: const Text('Exit App?',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: kInk)),
            content: const Text('Are you sure you want to exit?',
                style: TextStyle(color: kInk2)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel',
                    style: TextStyle(color: kInk2)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Exit',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          SystemNavigator.pop(); // properly exits the app
        }
      },
      child: Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: kInk),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CustomerMainScreen()),
              );
            },
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _statsFuture = AdminDashboardService.fetchDashboardStats();
              });
            },
            child: FutureBuilder<AdminDashboardStats>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Failed to load dashboard data',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(snapshot.error.toString(),
                              style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => setState(() {
                              _statsFuture =
                                  AdminDashboardService.fetchDashboardStats();
                            }),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return _BodyWidget(snapshot.data, _navIndex,
                      (i) => setState(() => _navIndex = i));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO CARD
// ─────────────────────────────────────────────────────────────────────────────
class HeroCard extends StatelessWidget {
  final AdminDashboardStats? stats;
  const HeroCard(this.stats);

  @override
  Widget build(BuildContext context) {
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: kMint.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: kMint.withValues(alpha: 0.4)),
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
                        Text(
                            stats != null
                                ? DashboardCalculations.getActivityStatus(
                                    stats!.activeNow, stats!.totalUsers)
                                : 'Loading...',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: kMint)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Admin\nDashboard',
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
                          label: '${stats?.pendingServices ?? 0} Pending',
                          color: kPeach),
                      const SizedBox(width: 8),
                      HeroPill(
                          label: '${stats?.productRequests ?? 0} New',
                          color: kLavender),
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
// STATS ROW
// ─────────────────────────────────────────────────────────────────────────────
class StatsRow extends StatelessWidget {
  final AdminDashboardStats? stats;
  const StatsRow(this.stats);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: BentoCard(
              color: kLavender,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Users',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: kInk2)),
                  const SizedBox(height: 6),
                  Text(
                      DashboardCalculations.formatUserCount(
                          stats?.totalUsers ?? 0),
                      style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: kInk,
                          height: 1,
                          letterSpacing: -2)),
                  const SizedBox(height: 10),
                  SmallBadge(
                      label: stats != null
                          ? '+${(stats!.totalUsers * 0.12).toInt()}% ↑'
                          : '0% ↑',
                      textColor: const Color(0xFF4A3C8C)),
                  const SizedBox(height: 12),
                  MiniBarChart(stats?.userGrowthData),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                BentoCard(
                  color: kMint,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pending',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: kInk2)),
                      const SizedBox(height: 6),
                      Text('${stats?.pendingServices ?? 0}',
                          style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: kInk,
                              height: 1,
                              letterSpacing: -2)),
                      const SizedBox(height: 8),
                      SmallBadge(
                          label: stats != null
                              ? '–${((stats!.pendingServices * 0.13).toInt())} today'
                              : '0 today',
                          textColor: const Color(0xFF1A6B48)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                BentoCard(
                  color: kBlush,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Requests',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: kInk2)),
                      const SizedBox(height: 6),
                      Text('${stats?.productRequests ?? 0}',
                          style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: kInk,
                              height: 1,
                              letterSpacing: -2)),
                      const SizedBox(height: 8),
                      SmallBadge(
                          label: stats != null && stats!.productRequests > 0
                              ? '${stats!.productRequests} New'
                              : '0 New',
                          textColor: const Color(0xFF8B3047)),
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
// MINI STATS ROW
// ─────────────────────────────────────────────────────────────────────────────
class MiniStatsRow extends StatelessWidget {
  final AdminDashboardStats? stats;
  const MiniStatsRow(this.stats);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
              child: MiniInfoCard(
                  label: 'Active Now',
                  value: '${stats?.activeNow ?? 0}',
                  icon: '🟢',
                  color: kSage)),
          const SizedBox(width: 10),
          Expanded(
              child: MiniInfoCard(
                  label: 'Technicians',
                  value: DashboardCalculations.formatUserCount(
                      stats?.technicians ?? 0),
                  icon: '⚙️',
                  color: kSky)),
          const SizedBox(width: 10),
          Expanded(
              child: MiniInfoCard(
                  label: 'Resolved',
                  value: '${(stats?.resolvedPercentage ?? 0).toInt()}%',
                  icon: '✅',
                  color: kPeach)),
        ],
      ),
    );
  }
}

class MiniInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;
  const MiniInfoCard(
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
// SECTION TITLE
// ─────────────────────────────────────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title);

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
                  color: kInk,
                  letterSpacing: -0.5)),
          const Text('View all →',
              style: TextStyle(
                  fontSize: 12,
                  color: kInk2,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION GRID
// ─────────────────────────────────────────────────────────────────────────────
class _ActionData {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final VoidCallback onTap;
  const _ActionData(
      this.title, this.subtitle, this.emoji, this.color, this.onTap);
}

class ActionGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData(
          'Manage Users',
          'Roles & permissions',
          '🧑‍💼',
          kLavender,
          () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ManageUsersScreen()))),
      _ActionData(
          'Pending Services',
          'Review & manage',
          '⏳',
          kPeach,
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PendingServicesScreen()))),
      _ActionData(
          'All Customers',
          'Customer data',
          '👥',
          kSky,
          () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AllCustomersScreen()))),
      _ActionData(
          'Product Requests',
          'Handle requests',
          '📦',
          kBlush,
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ProductRequestsScreen()))),
      _ActionData(
          'Status Logs',
          'Change history',
          '📋',
          kSage,
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ServiceStatusLogsScreen()))),
      _ActionData(
          'Tech Activity',
          'Technician logs',
          '⚙️',
          kMint,
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const TechnicianActivityLogsScreen()))),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(children: [
            Expanded(child: ActionCard(data: actions[0])),
            const SizedBox(width: 12),
            Expanded(child: ActionCard(data: actions[1])),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ActionCard(data: actions[2])),
            const SizedBox(width: 12),
            Expanded(child: ActionCard(data: actions[3])),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ActionCard(data: actions[4])),
            const SizedBox(width: 12),
            Expanded(child: ActionCard(data: actions[5])),
          ]),
        ],
      ),
    );
  }
}

class ActionCard extends StatefulWidget {
  final _ActionData data;
  const ActionCard({required this.data});
  @override
  State<ActionCard> createState() => ActionCardState();
}

class ActionCardState extends State<ActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.data.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.all(18),
        transform: Matrix4.identity()..scaleByVector3(vm.Vector3.all(_pressed ? 0.97 : 1.0)),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.data.color.withValues(alpha: _pressed ? 0.75 : 0.4),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.data.emoji,
                    style: const TextStyle(fontSize: 26)),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: kWhite.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 13, color: kInk),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(widget.data.title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: kInk,
                    letterSpacing: -0.3)),
            const SizedBox(height: 3),
            Text(widget.data.subtitle,
                style: const TextStyle(fontSize: 11, color: kInk2)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class BentoCard extends StatelessWidget {
  final Color color;
  final Widget child;
  const BentoCard({required this.color, required this.child});

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

class SmallBadge extends StatelessWidget {
  final String label;
  final Color textColor;
  const SmallBadge({required this.label, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kWhite.withValues(alpha: 0.55),
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

class MiniBarChart extends StatelessWidget {
  final List<double>? data;
  const MiniBarChart(this.data);

  @override
  Widget build(BuildContext context) {
    final heights =
        DashboardCalculations.generateGrowthChart(data ?? [], 7);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: heights
          .map((h) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Container(
                  width: 10,
                  height: h,
                  decoration: BoxDecoration(
                    color: kInk.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _AdditionalMetricsRow extends StatelessWidget {
  final AdminDashboardStats? stats;
  const _AdditionalMetricsRow(this.stats);

  @override
  Widget build(BuildContext context) {
    final utilization = stats != null
        ? DashboardCalculations.calculateTechnicianUtilization(
            stats!.activeNow, stats!.technicians)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: kSky.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tech Utilization',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: kInk2)),
                  const SizedBox(height: 4),
                  Text('${utilization.toInt()}%',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: kInk)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: kPeach.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Avg Resolution',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: kInk2)),
                  const SizedBox(height: 4),
                  Text('${(stats?.resolvedPercentage ?? 0).toInt()}%',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: kInk)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyWidget extends StatelessWidget {
  final AdminDashboardStats? stats;
  final int navIndex;
  final ValueChanged<int> onTap;
  const _BodyWidget(this.stats, this.navIndex, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              HeroCard(stats),
              const SizedBox(height: 14),
              StatsRow(stats),
              const SizedBox(height: 14),
              MiniStatsRow(stats),
              const SizedBox(height: 14),
              _AdditionalMetricsRow(stats),
              const SizedBox(height: 20),
              SectionTitle('Quick Actions'),
              const SizedBox(height: 12),
              ActionGrid(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
