import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'dart:math' as math;
import '../models/technician_service.dart';
import '../services/technician_api.dart';
import '../../auth/screens/login_screen.dart';
import '../../customer/screens/customer_main_screen.dart';
import 'installation_jobs_screen.dart';

// ─── PALETTE ─────────────────────────────────────────────────────────────────
const _bg       = Color(0xFFF5F4F0);
const _white    = Color(0xFFFFFFFF);
const _ink      = Color(0xFF111110);
const _ink2     = Color(0xFF8A8880);
const _darkPill = Color(0xFF1A1A18);
const _lavender = Color(0xFFD5CCFF);
const _mint     = Color(0xFFBDF0D8);
const _blush    = Color(0xFFF5C8D4);
const _sky      = Color(0xFFBFE0F5);
const _peach    = Color(0xFFF8DBBF);
const _sage     = Color(0xFFC8DFC0);

// ─────────────────────────────────────────────────────────────────────────────
class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({super.key});

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen>
    with TickerProviderStateMixin {
  late Future<List<TechnicianService>> _servicesFuture;
  late AnimationController _headerController;
  late AnimationController _refreshController;
  late Animation<double> _headerAnimation;


  @override
  void initState() {
    super.initState();
    _servicesFuture = TechnicianApi.getUpcomingServices();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _refresh() {
    _refreshController.forward(from: 0);
    setState(() {
      _servicesFuture = TechnicianApi.getUpcomingServices();
    });
  }

  Future<void> _complete(TechnicianService s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmDialog(service: s),
    );

    if (confirm == true) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 48),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: _darkPill, strokeWidth: 2.5),
                SizedBox(height: 16),
                Text('Completing service…',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _ink)),
              ],
            ),
          ),
        ),
      );

      try {
        await TechnicianApi.completeService(
          serviceId: s.serviceId,
          customerId: s.customerId,
        );
        if (!mounted) return;
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Text('✅', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Text('Service ${s.serviceNumber} completed!',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
            backgroundColor: _darkPill,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
          ),
        );
        _refresh();
      } catch (e) {
        if (!mounted) return;
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Text('❌', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              const Expanded(
                  child: Text('Failed to complete service',
                      style: TextStyle(fontWeight: FontWeight.w600))),
            ]),
            backgroundColor: const Color(0xFFB03050),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _showCustomerDetails(TechnicianService s) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FutureBuilder(
        future: TechnicianApi.getCustomerInfo(s.customerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _BottomSheetLoading();
          }
          if (!snapshot.hasData) {
            return const _BottomSheetError();
          }
          return _CustomerBottomSheet(customer: snapshot.data!, service: s);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final isWide = MediaQuery.of(context).size.width >= 640;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _ink),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CustomerMainScreen()),
            );
          },
        ),
        title: const Text(
          'Technician Portal',
          style: TextStyle(
            color: _ink,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: _ink),
      ),
      body: SafeArea(
        child: isWide
            ? _DesktopLayout(
                servicesFuture: _servicesFuture,
                headerAnimation: _headerAnimation,
                refreshController: _refreshController,
                onRefresh: _refresh,
                onComplete: _complete,
                onShowDetails: _showCustomerDetails,
              )
            : _MobileLayout(
                servicesFuture: _servicesFuture,
                headerAnimation: _headerAnimation,
                refreshController: _refreshController,
                onRefresh: _refresh,
                onComplete: _complete,
                onShowDetails: _showCustomerDetails,
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE LAYOUT
// ─────────────────────────────────────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final Future<List<TechnicianService>> servicesFuture;
  final Animation<double> headerAnimation;
  final AnimationController refreshController;
  final VoidCallback onRefresh;
  final Future<void> Function(TechnicianService) onComplete;
  final Future<void> Function(TechnicianService) onShowDetails;

  const _MobileLayout({
    required this.servicesFuture,
    required this.headerAnimation,
    required this.refreshController,
    required this.onRefresh,
    required this.onComplete,
    required this.onShowDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          color: _darkPill,
          backgroundColor: _white,
          onRefresh: () async => onRefresh(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: headerAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, -0.2), end: Offset.zero)
                        .animate(headerAnimation),
                    child: _HeroHeader(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FutureBuilder<List<TechnicianService>>(
                  future: servicesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _LoadingState();
                    }
                    if (snapshot.hasError) {
                      return _ErrorState(
                          error: snapshot.error.toString(),
                          onRetry: onRefresh);
                    }
                    final services = snapshot.data ?? [];
                    return _ServicesList(
                      services: services,
                      onComplete: onComplete,
                      onShowDetails: onShowDetails,
                      isWide: false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: _RefreshFab(
              controller: refreshController, onTap: onRefresh),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DESKTOP LAYOUT
// ─────────────────────────────────────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  final Future<List<TechnicianService>> servicesFuture;
  final Animation<double> headerAnimation;
  final AnimationController refreshController;
  final VoidCallback onRefresh;
  final Future<void> Function(TechnicianService) onComplete;
  final Future<void> Function(TechnicianService) onShowDetails;

  const _DesktopLayout({
    required this.servicesFuture,
    required this.headerAnimation,
    required this.refreshController,
    required this.onRefresh,
    required this.onComplete,
    required this.onShowDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
            child: Column(
              children: [
                FadeTransition(
                  opacity: headerAnimation,
                  child: _HeroHeader(tall: true),
                ),
                const SizedBox(height: 14),
                _InstallationCard(),
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: _darkPill,
            backgroundColor: _white,
            onRefresh: () async => onRefresh(),
            child: FutureBuilder<List<TechnicianService>>(
              future: servicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _LoadingState();
                }
                if (snapshot.hasError) {
                  return _ErrorState(
                      error: snapshot.error.toString(), onRetry: onRefresh);
                }
                final services = snapshot.data ?? [];
                return _ServicesList(
                  services: services,
                  onComplete: onComplete,
                  onShowDetails: onShowDetails,
                  isWide: true,
                  hideInstallationCard: true,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final bool tall;
  const _HeroHeader({this.tall = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: tall
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _darkPill,
          borderRadius: BorderRadius.circular(28),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              top: -30, right: -20,
              child: Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _lavender.withValues(alpha: 0.15),
                ),
              ),
            ),
            Positioned(
              bottom: -20, right: 60,
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _mint.withValues(alpha: 0.12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _mint.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: _mint.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                              color: _mint, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        const Text('On Duty',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _mint)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Technician\nPortal',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: _white,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _HeroPill(label: '⚙️ Services', color: _peach),
                      _HeroPill(label: '💧 PureCare', color: _lavender),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICES LIST
// ─────────────────────────────────────────────────────────────────────────────
class _ServicesList extends StatelessWidget {
  final List<TechnicianService> services;
  final Future<void> Function(TechnicianService) onComplete;
  final Future<void> Function(TechnicianService) onShowDetails;
  final bool isWide;
  final bool hideInstallationCard;

  const _ServicesList({
    required this.services,
    required this.onComplete,
    required this.onShowDetails,
    this.isWide = false,
    this.hideInstallationCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = isWide
        ? const EdgeInsets.fromLTRB(10, 20, 20, 32)
        : const EdgeInsets.fromLTRB(16, 16, 16, 100);

    if (services.isEmpty) {
      return Padding(
        padding: padding,
        child: Column(
          children: [
            _EmptyBento(),
            if (!hideInstallationCard) ...[
              const SizedBox(height: 14),
              _InstallationCard(),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Upcoming Services',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                      letterSpacing: -0.5)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _lavender.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${services.length} ${services.length == 1 ? 'job' : 'jobs'}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!hideInstallationCard) ...[
            _InstallationCard(),
            const SizedBox(height: 14),
          ],
          isWide
              ? _WideGrid(
                  services: services,
                  onComplete: onComplete,
                  onShowDetails: onShowDetails)
              : _NarrowList(
                  services: services,
                  onComplete: onComplete,
                  onShowDetails: onShowDetails),
        ],
      ),
    );
  }
}

class _WideGrid extends StatelessWidget {
  final List<TechnicianService> services;
  final Future<void> Function(TechnicianService) onComplete;
  final Future<void> Function(TechnicianService) onShowDetails;
  const _WideGrid(
      {required this.services,
      required this.onComplete,
      required this.onShowDetails});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < services.length; i += 2) {
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _ServiceCard(
              service: services[i],
              index: i,
              onComplete: onComplete,
              onShowDetails: onShowDetails,
            ),
          ),
          const SizedBox(width: 12),
          if (i + 1 < services.length)
            Expanded(
              child: _ServiceCard(
                service: services[i + 1],
                index: i + 1,
                onComplete: onComplete,
                onShowDetails: onShowDetails,
              ),
            )
          else
            const Expanded(child: SizedBox()),
        ],
      ));
      rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }
}

class _NarrowList extends StatelessWidget {
  final List<TechnicianService> services;
  final Future<void> Function(TechnicianService) onComplete;
  final Future<void> Function(TechnicianService) onShowDetails;
  const _NarrowList(
      {required this.services,
      required this.onComplete,
      required this.onShowDetails});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(services.length, (i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _ServiceCard(
          service: services[i],
          index: i,
          onComplete: onComplete,
          onShowDetails: onShowDetails,
        ),
      )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICE CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ServiceCard extends StatefulWidget {
  final TechnicianService service;
  final int index;
  final Future<void> Function(TechnicianService) onComplete;
  final Future<void> Function(TechnicianService) onShowDetails;

  const _ServiceCard({
    required this.service,
    required this.index,
    required this.onComplete,
    required this.onShowDetails,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _pressed = false;

  static const _colors = [
    _lavender, _mint, _sky, _peach, _blush, _sage,
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _colors[widget.index % _colors.length];
    final s = widget.service;

    return GestureDetector(
      onTap: () => widget.onShowDetails(s),
      child: Container(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('🔧', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service ${s.serviceNumber}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Customer #${s.customerId}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: _ink2,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 11, color: _ink2),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                  color: _ink.withValues(alpha: 0.08), height: 1, thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Service Date',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _ink2)),
                        const SizedBox(height: 1),
                        Text(s.serviceDate,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _ink)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: GestureDetector(
                onTap: () => widget.onComplete(s),
                onTapDown: (_) => setState(() => _pressed = true),
                onTapUp: (_) => setState(() => _pressed = false),
                onTapCancel: () => setState(() => _pressed = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 130),
                  height: 48,
                  transform: Matrix4.identity()
                    ..scaleByVector3(vm.Vector3.all(_pressed ? 0.97 : 1.0)),
                  transformAlignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _pressed
                        ? _darkPill.withValues(alpha: 0.82)
                        : _darkPill,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('✅', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 8),
                      Text('Mark as Complete',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _white,
                              letterSpacing: 0.1)),
                    ],
                  ),
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
// INSTALLATION REQUESTS CARD
// ─────────────────────────────────────────────────────────────────────────────
class _InstallationCard extends StatefulWidget {
  @override
  State<_InstallationCard> createState() => _InstallationCardState();
}

class _InstallationCardState extends State<_InstallationCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const InstallationJobsScreen()),
      ),
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        transform: Matrix4.identity()..scaleByVector3(vm.Vector3.all(_pressed ? 0.97 : 1.0)),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _sky.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: _sky.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('📦', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Installation Requests',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                          letterSpacing: -0.2)),
                  SizedBox(height: 3),
                  Text('View assigned installation jobs',
                      style: TextStyle(
                          fontSize: 11,
                          color: _ink2,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: _white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: _ink),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY BENTO
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyBento extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _sage.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _sage.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Text('🎉', style: TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 16),
          const Text('All Caught Up!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  letterSpacing: -0.4)),
          const SizedBox(height: 6),
          const Text('No upcoming services.\nEnjoy your break!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: _ink2, height: 1.5)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONFIRM DIALOG
// ─────────────────────────────────────────────────────────────────────────────
class _ConfirmDialog extends StatelessWidget {
  final TechnicianService service;
  const _ConfirmDialog({required this.service});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _bg,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _peach.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Text('✅', style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 16),
            const Text('Complete Service?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                    letterSpacing: -0.4)),
            const SizedBox(height: 8),
            Text(
              'Mark Service ${service.serviceNumber} as completed?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: _ink2, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: _ink.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Text('Cancel',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _ink2)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: _darkPill,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Text('Confirm',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOMER BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _CustomerBottomSheet extends StatelessWidget {
  final dynamic customer;
  final TechnicianService service;
  const _CustomerBottomSheet(
      {required this.customer, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: _ink.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _lavender.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('👤', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Customer Details',
                        style: TextStyle(
                            fontSize: 11,
                            color: _ink2,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(
                      customer.name ?? '—',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                          letterSpacing: -0.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _InfoTile(
              emoji: '📱',
              label: 'Phone Number',
              value: customer.phone ?? '—',
              color: _mint),
          const SizedBox(height: 10),
          _InfoTile(
              emoji: '📍',
              label: 'Address',
              value: customer.address ?? '—',
              color: _sky),
          const SizedBox(height: 10),
          _InfoTile(
              emoji: '🔢',
              label: 'Service Number',
              value: service.serviceNumber.toString(),
              color: _peach),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;
  const _InfoTile(
      {required this.emoji,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _ink2)),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM SHEET STATES
// ─────────────────────────────────────────────────────────────────────────────
class _BottomSheetLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(40),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _darkPill, strokeWidth: 2.5),
          SizedBox(height: 16),
          Text('Loading customer details…',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _ink2)),
        ],
      ),
    );
  }
}

class _BottomSheetError extends StatelessWidget {
  const _BottomSheetError();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(40),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('❌', style: TextStyle(fontSize: 36)),
          SizedBox(height: 16),
          Text('Failed to load customer info',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _ink)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADING STATE
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _darkPill, strokeWidth: 2.5),
            SizedBox(height: 16),
            Text('Loading services…',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _ink2)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR STATE
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: _blush.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Text('❌', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(height: 16),
              const Text('Could not load services',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                      letterSpacing: -0.4)),
              const SizedBox(height: 8),
              Text(error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, color: _ink2, height: 1.5)),
              const SizedBox(height: 24),
              _RetryButton(onTap: onRetry),
            ],
          ),
        ),
      ),
    );
  }
}

class _RetryButton extends StatefulWidget {
  final VoidCallback onTap;
  const _RetryButton({required this.onTap});

  @override
  State<_RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<_RetryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
        transform: Matrix4.identity()..scaleByVector3(vm.Vector3.all(_pressed ? 0.97 : 1.0)),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _darkPill,
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔄', style: TextStyle(fontSize: 14)),
            SizedBox(width: 8),
            Text('Retry',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _white)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REFRESH FAB
// ─────────────────────────────────────────────────────────────────────────────
class _RefreshFab extends StatelessWidget {
  final AnimationController controller;
  final VoidCallback onTap;
  const _RefreshFab({required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RotationTransition(
        turns: controller,
        child: Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: _darkPill,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _darkPill.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text('🔄', style: TextStyle(fontSize: 20)),
          ),
        ),
      ),
    );
  }
}
