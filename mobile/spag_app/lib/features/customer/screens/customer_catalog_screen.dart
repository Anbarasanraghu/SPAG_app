import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../../../core/models/purifier_model.dart';
import '../../../core/api/purifier_service.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/controller/auth_controller.dart';
import '../../../core/ui/ui_kit.dart';
import 'customer_home_decider_screen.dart';
import 'product_selection_screen.dart';

// ─── PALETTE (matches Admin Dashboard) ───────────────────────────────────────
const _bg       = Color(0xFFF5F4F0);
const _white    = Color(0xFFFFFFFF);
const _ink      = Color(0xFF111110);
const _ink2     = Color(0xFF8A8880);
const _darkPill = Color(0xFF1A1A18);

const _lavender = Color(0xFFD5CCFF);
const _mint     = Color(0xFFBDF0D8);
const _blush    = Color(0xFFF5C8D4);
const _sage     = Color(0xFFC8DFC0);
const _sky      = Color(0xFFBFE0F5);
const _peach    = Color(0xFFF8DBBF);

// Card accent colors cycling for each purifier card
const _cardAccents = [_lavender, _mint, _peach, _sky, _blush, _sage];

// ─────────────────────────────────────────────────────────────────────────────
class CustomerCatalogScreen extends StatefulWidget {
  const CustomerCatalogScreen({super.key});

  @override
  State<CustomerCatalogScreen> createState() => _CustomerCatalogScreenState();
}

class _CustomerCatalogScreenState extends State<CustomerCatalogScreen> {
  late Future<List<PurifierModel>> _modelsFuture;
  int? _requestingId;
  String? role;

  Future<void> _loadRole() async {
    final r = await AuthService.getRole();
    if (!mounted) return;
    setState(() => role = r);
  }

  Future<List<PurifierModel>> _fetchModels() {
    return PurifierService.listModels().then((models) {
      debugPrint("[CustomerCatalog] Loaded ${models.length} models");
      return models;
    }).catchError((e) {
      debugPrint("[CustomerCatalog] Error loading models: $e");
      throw e;
    });
  }

  // ── COLOUR CONSTANTS ─────────────────────────────────────
  static const Color _bg        = Color(0xFFF5F9FF);
  static const Color _panel     = Color(0xFFFFFFFF);
  static const Color _surface   = Color(0xFFEAF3FF);
  static const Color _accent    = Color(0xFF2A8FD4);
  static const Color _mid       = Color(0xFF5AABDE);
  static const Color _soft      = Color(0xFFC4DFF5);
  static const Color _text      = Color(0xFF0D2A3F);
  static const Color _muted     = Color(0xFF6B8FA8);
  static const Color _hairline  = Color(0xFFD6E8F5);

  @override
  void initState() {
    super.initState();

    // 🔍 Debug token existence
    AuthService.getToken().then((token) {
      debugPrint("CUSTOMER CATALOG TOKEN => $token");
    });

    _modelsFuture = _fetchModels();

    _loadRole();
  }

  PreferredSizeWidget _buildAppBar() {
    final titles = ['Products', 'My Requests', 'Profile'];

    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        color: _ink,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProductSelectionScreen()),
          );
        },
      ),
      title: Text(
        titles[0],
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: _ink,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        if (role == null) ...[
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/login'),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _darkPill,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  color: _white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ] else ...[
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/customer-dashboard'),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _sky.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.dashboard_rounded,
                color: _ink,
                size: 20,
              ),
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(child: SpagCornerBadge()),
        ),
      ],
    );
  }

  Future<void> _request(int id) async {
    setState(() => _requestingId = id);
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        final result = await showModalBottomSheet<Map<String, String>?>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _AnonRequestSheet(modelId: id),
        );

        if (result?['success'] != 'true') return;
        if (result?['success'] != 'true') return;
      } else {
        await PurifierService.requestProduct(id);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: _ink),
              SizedBox(width: 12),
              Text('Request submitted successfully!',
                  style: TextStyle(color: _ink, fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: _mint,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CustomerHomeDeciderScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: _ink),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Error: $e',
                      style: const TextStyle(color: _ink, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            backgroundColor: _blush,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _requestingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: _ink,
          backgroundColor: _white,
          onRefresh: () async {
            setState(() {
              _modelsFuture = PurifierService.listModels();
            });
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── HERO SLIVER ──────────────────────────────────────────────
              SliverToBoxAdapter(child: _CatalogHero()),

              // ── SECTION LABEL ────────────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Available Models',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                              letterSpacing: -0.5)),
                      Text('Tap to request →',
                          style: TextStyle(
                              fontSize: 12, color: _ink2, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),

              // ── CONTENT ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: FutureBuilder<List<PurifierModel>>(
                  future: _modelsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _LoadingState();
                    }
                    if (snapshot.hasError) {
                      return _ErrorState(
                        error: snapshot.error.toString(),
                        onRetry: () => setState(() {
                          _modelsFuture = _fetchModels();
                        }),
                      );
                    }
                    final models = snapshot.data ?? [];
                    if (models.isEmpty) {
                      return const _EmptyState();
                    }
                    return _ModelList(
                      models: models,
                      requestingId: _requestingId,
                      onRequest: _request,
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO — matches Admin Dashboard dark pill style
// ─────────────────────────────────────────────────────────────────────────────
class _CatalogHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: _darkPill,
          borderRadius: BorderRadius.circular(30),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // decorative circles
            Positioned(
              top: -30, right: -20,
              child: Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _sky.withValues(alpha: 0.18),
                ),
              ),
            ),
            Positioned(
              bottom: -20, right: 60,
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _mint.withValues(alpha: 0.15),
                ),
              ),
            ),
            Positioned(
              left: -20, top: 20,
              child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _peach.withValues(alpha: 0.12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // active badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _sky.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: _sky.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(color: _sky, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        const Text('Purifier Catalog',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600, color: _sky)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Choose Your Purifier',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: _white,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _HeroPill(label: '💧 Water Purifiers', color: _sky),
                      const SizedBox(width: 8),
                      _HeroPill(label: '✅ Free Service', color: _mint),
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
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODEL LIST — responsive grid/list
// ─────────────────────────────────────────────────────────────────────────────
class _ModelList extends StatelessWidget {
  final List<PurifierModel> models;
  final int? requestingId;
  final ValueChanged<int> onRequest;

  const _ModelList({
    required this.models,
    required this.requestingId,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final isTablet = width >= 600 && width < 900;

    if (isDesktop) {
      // 3-column grid for desktop
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _buildGrid(3),
      );
    } else if (isTablet) {
      // 2-column grid for tablet
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _buildGrid(2),
      );
    } else {
      // Single column for mobile
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: List.generate(models.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PurifierCard(
                model: models[i],
                accentColor: _cardAccents[i % _cardAccents.length],
                isRequesting: requestingId == models[i].id,
                isDisabled: requestingId != null,
                onRequest: onRequest,
              ),
            );
          }),
        ),
      );
    }
  }

  Widget _buildGrid(int crossAxisCount) {
    return LayoutBuilder(builder: (context, constraints) {
      final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * 12) / crossAxisCount;
      final rows = <Widget>[];
      for (int i = 0; i < models.length; i += crossAxisCount) {
        final rowItems = <Widget>[];
        for (int j = 0; j < crossAxisCount; j++) {
          final idx = i + j;
          if (idx < models.length) {
            rowItems.add(SizedBox(
              width: itemWidth,
              child: _PurifierCard(
                model: models[idx],
                accentColor: _cardAccents[idx % _cardAccents.length],
                isRequesting: requestingId == models[idx].id,
                isDisabled: requestingId != null,
                onRequest: (id) => onRequest(id),
              ),
            ));
          } else {
            rowItems.add(SizedBox(width: itemWidth));
          }
          if (j < crossAxisCount - 1) rowItems.add(const SizedBox(width: 12));
        }
        rows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowItems,
        ));
        rows.add(const SizedBox(height: 16));
      }
      return Column(children: rows);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PURIFIER CARD — bento pastel style
// ─────────────────────────────────────────────────────────────────────────────
class _PurifierCard extends StatefulWidget {
  final PurifierModel model;
  final Color accentColor;
  final bool isRequesting;
  final bool isDisabled;
  final ValueChanged<int> onRequest;

  const _PurifierCard({
    required this.model,
    required this.accentColor,
    required this.isRequesting,
    required this.isDisabled,
    required this.onRequest,
  });

  @override
  State<_PurifierCard> createState() => _PurifierCardState();
}

class _PurifierCardState extends State<_PurifierCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.model;
    final accent = widget.accentColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        transform: Matrix4.identity()..scaleByVector3(vm.Vector3.all(_pressed ? 0.98 : 1.0)),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(26),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: icon + model badge ────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _darkPill,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.water_drop, color: _white, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Model #${m.id}',
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w700, color: _ink2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ── Stats row ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatChip(
                    emoji: '🔧',
                    label: 'Free Services',
                    value: '${m.freeServices}',
                    bgColor: _white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatChip(
                    emoji: '📅',
                    label: 'Interval',
                    value: '${m.serviceIntervalDays}d',
                    bgColor: _white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Additional info row ──────────────────────────────────────
            if (m.price != null || m.capacity != null)
              Row(
                children: [
                  if (m.price != null)
                    Expanded(
                      child: _StatChip(
                        emoji: '💰',
                        label: 'Price',
                        value: '₹${m.price!.toStringAsFixed(0)}',
                        bgColor: _white.withValues(alpha: 0.6),
                      ),
                    ),
                  if (m.price != null && m.capacity != null) const SizedBox(width: 10),
                  if (m.capacity != null)
                    Expanded(
                      child: _StatChip(
                        emoji: '🪣',
                        label: 'Capacity',
                        value: m.capacity!,
                        bgColor: _white.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),

            if (m.category != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Text('🏷️', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      'Category: ${m.category}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (m.descriptions != null && m.descriptions!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  m.descriptions!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _ink2,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // ── CTA Button ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: GestureDetector(
                onTap: widget.isDisabled ? null : () => widget.onRequest(m.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  decoration: BoxDecoration(
                    color: widget.isDisabled ? _ink.withValues(alpha: 0.1) : _darkPill,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: widget.isRequesting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: _white, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: widget.isDisabled ? _ink2 : _white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Request Purifier',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: widget.isDisabled ? _ink2 : _white,
                                letterSpacing: 0.2,
                              ),
                            ),
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
// STAT CHIP — small info block inside card
// ─────────────────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color bgColor;

  const _StatChip({
    required this.emoji,
    required this.label,
    required this.value,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _ink,
                  height: 1)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w600, color: _ink2)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADING STATE
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: _sky.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: _darkPill, strokeWidth: 3),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Loading purifiers…',
                style: TextStyle(
                    fontSize: 14,
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
    // Keep the raw error available for debugging if needed.
    debugPrint('Catalog error: $error');

    return ErrorStateCard(
      title: 'Failed to load requests',
      message:
          'You need to be logged in to view your requests. Please log in and try again.',
      onRetry: onRetry,
      onLogin: () => Navigator.of(context).pushNamed('/login'),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _sage.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: _white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text('💧', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('No purifiers available',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _ink)),
            const SizedBox(height: 6),
            const Text('Please check back later',
                style: TextStyle(fontSize: 12, color: _ink2)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANON REQUEST BOTTOM SHEET — styled to match dashboard
// ─────────────────────────────────────────────────────────────────────────────
class _AnonRequestSheet extends StatefulWidget {
  final int modelId;
  const _AnonRequestSheet({required this.modelId});

  @override
  State<_AnonRequestSheet> createState() => _AnonRequestSheetState();
}

class _AnonRequestSheetState extends State<_AnonRequestSheet> {
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // handle bar
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

          // title
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _lavender.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('📦', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Request Product',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _ink)),
                    Text('Enter your details below',
                        style: TextStyle(fontSize: 11, color: _ink2)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _StyledField(controller: _phoneCtrl, label: 'Mobile Number', emoji: '📱', keyboard: TextInputType.phone),
          const SizedBox(height: 12),
          _StyledField(controller: _emailCtrl, label: 'Gmail', emoji: '✉️', keyboard: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _StyledField(controller: _passCtrl, label: 'Password', emoji: '🔒', obscure: true),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: GestureDetector(
              onTap: _loading
                  ? null
                  : () async {
                      if (_phoneCtrl.text.trim().isEmpty ||
                          _emailCtrl.text.trim().isEmpty ||
                          _passCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('All fields required',
                                style: TextStyle(color: _ink, fontWeight: FontWeight.w600)),
                            backgroundColor: _peach,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                        return;
                      }
                      setState(() => _loading = true);
                      try {
                        await PurifierService.requestProduct(
                          widget.modelId,
                          mobile: _phoneCtrl.text.trim(),
                          gmail: _emailCtrl.text.trim(),
                          password: _passCtrl.text,
                        );
                        Navigator.pop(context, {'success': 'true'});
                      } catch (e) {
                        setState(() => _loading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Request error: $e',
                                style: const TextStyle(color: _ink, fontWeight: FontWeight.w600)),
                            backgroundColor: _blush,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      }
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                decoration: BoxDecoration(
                  color: _loading ? _darkPill.withValues(alpha: 0.5) : _darkPill,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(color: _white, strokeWidth: 2.5),
                      )
                    : const Text('Submit Request',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STYLED TEXT FIELD
// ─────────────────────────────────────────────────────────────────────────────
class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String emoji;
  final TextInputType keyboard;
  final bool obscure;

  const _StyledField({
    required this.controller,
    required this.label,
    required this.emoji,
    this.keyboard = TextInputType.text,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        obscureText: obscure,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _ink),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: _ink2, fontWeight: FontWeight.w500),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
