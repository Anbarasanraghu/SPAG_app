import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../../../core/models/purifier_model.dart';
import '../../../core/api/purifier_service.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/ui/ui_kit.dart';
import 'customer_home_decider_screen.dart';
import 'product_selection_screen.dart';

// ─── PALETTE ─────────────────────────────────────────────────────────────────
const _bg       = Color(0xFFF5F4F0);
const _white    = Color(0xFFFFFFFF);
const _ink      = Color(0xFF111110);
const _ink2     = Color(0xFF8A8880);
const _darkPill = Color(0xFF1A1A18);
const _surface  = Color(0xFFEEEDEB);

const _lavender = Color(0xFFD5CCFF);
const _mint     = Color(0xFFBDF0D8);
const _blush    = Color(0xFFF5C8D4);
const _sage     = Color(0xFFC8DFC0);
const _sky      = Color(0xFFBFE0F5);
const _peach    = Color(0xFFF8DBBF);

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

  // ── Filter / Search / Sort state ──────────────────────────────────────────
  final _searchCtrl = TextEditingController();
  String _activeFilter = 'all'; // 'all' | 'standard' | 'premium'
  String _sortBy = 'name';      // 'name' | 'price_asc' | 'price_desc' | 'capacity'
  List<PurifierModel> _allModels = [];
  List<PurifierModel> _filtered  = [];

  Future<void> _loadRole() async {
    final r = await AuthService.getRole();
    if (!mounted) return;
    setState(() => role = r);
  }

  Future<List<PurifierModel>> _fetchModels() {
    return PurifierService.listModels().then((models) {
      _allModels = models;
      _applyFilter();
      return models;
    });
  }

  void _applyFilter() {
    List<PurifierModel> list = List.from(_allModels);
    final q = _searchCtrl.text.trim().toLowerCase();

    if (_activeFilter != 'all') {
      list = list.where((m) => (m.category ?? '').toLowerCase() == _activeFilter).toList();
    }
    if (q.isNotEmpty) {
      list = list.where((m) =>
        m.name.toLowerCase().contains(q) ||
        (m.features ?? '').toLowerCase().contains(q) ||
        (m.colours ?? '').toLowerCase().contains(q) ||
        (m.capacity ?? '').toLowerCase().contains(q)
      ).toList();
    }
    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case 'price_desc':
        list.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case 'capacity':
        list.sort((a, b) {
          final al = _extractLitres(a.capacity);
          final bl = _extractLitres(b.capacity);
          return al.compareTo(bl);
        });
        break;
      default:
        list.sort((a, b) => a.name.compareTo(b.name));
    }
    setState(() => _filtered = list);
  }

  int _extractLitres(String? cap) {
    if (cap == null) return 0;
    final m = RegExp(r'(\d+)').firstMatch(cap);
    return m != null ? int.tryParse(m.group(1) ?? '0') ?? 0 : 0;
  }

  @override
  void initState() {
    super.initState();
    AuthService.getToken().then((token) {
      debugPrint("CUSTOMER CATALOG TOKEN => $token");
    });
    _modelsFuture = _fetchModels();
    _loadRole();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── REQUEST ──────────────────────────────────────────────────────────────
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
      } else {
        await PurifierService.requestProduct(id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: _ink),
            SizedBox(width: 12),
            Text('Request submitted!', style: TextStyle(color: _ink, fontWeight: FontWeight.w600)),
          ]),
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
            content: Row(children: [
              const Icon(Icons.error_outline, color: _ink),
              const SizedBox(width: 12),
              Expanded(child: Text('Error: $e', style: const TextStyle(color: _ink, fontWeight: FontWeight.w600))),
            ]),
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

  // ── DETAIL SHEET ─────────────────────────────────────────────────────────
  void _openDetail(PurifierModel model, Color accent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductDetailSheet(
        model: model,
        accent: accent,
        requestingId: _requestingId,
        onRequest: _request,
      ),
    );
  }

  // ── APP BAR ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        color: _ink,
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProductSelectionScreen()),
        ),
      ),
      title: const Text('Products',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _ink, letterSpacing: -0.5)),
      actions: [
        if (role == null)
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/login'),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: _darkPill, borderRadius: BorderRadius.circular(100)),
              child: const Text('Login',
                  style: TextStyle(color: _white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          )
        else
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/customer-dashboard'),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _sky.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.dashboard_rounded, color: _ink, size: 20),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(child: SpagCornerBadge()),
        ),
      ],
    );
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
                  _allModels = [];
                  _filtered  = [];
                  _modelsFuture = _fetchModels();
                }),
              );
            }
            return RefreshIndicator(
              color: _ink,
              backgroundColor: _white,
              onRefresh: () async {
                _allModels = [];
                _filtered  = [];
                setState(() {
                  _modelsFuture = _fetchModels();
                });
                await _modelsFuture;
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── HERO ────────────────────────────────────────────
                  SliverToBoxAdapter(child: _CatalogHero()),

                  // ── SEARCH + FILTERS ─────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search bar
                          Container(
                            decoration: BoxDecoration(
                              color: _white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: _searchCtrl,
                              style: const TextStyle(fontSize: 14, color: _ink),
                              decoration: InputDecoration(
                                hintText: 'Search by name, technology, colour…',
                                hintStyle: const TextStyle(fontSize: 13, color: _ink2),
                                prefixIcon: const Icon(Icons.search_rounded, color: _ink2, size: 20),
                                suffixIcon: _searchCtrl.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close_rounded, color: _ink2, size: 18),
                                        onPressed: () {
                                          _searchCtrl.clear();
                                          _applyFilter();
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Filter pills + Sort
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _FilterPill(
                                  label: 'All',
                                  active: _activeFilter == 'all',
                                  onTap: () { setState(() => _activeFilter = 'all'); _applyFilter(); },
                                ),
                                const SizedBox(width: 8),
                                _FilterPill(
                                  label: 'Standard',
                                  active: _activeFilter == 'standard',
                                  onTap: () { setState(() => _activeFilter = 'standard'); _applyFilter(); },
                                ),
                                const SizedBox(width: 8),
                                _FilterPill(
                                  label: 'Premium',
                                  active: _activeFilter == 'premium',
                                  onTap: () { setState(() => _activeFilter = 'premium'); _applyFilter(); },
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _white,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _sortBy,
                                      isDense: true,
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: _ink2),
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _ink),
                                      items: const [
                                        DropdownMenuItem(value: 'name',       child: Text('Sort: Name')),
                                        DropdownMenuItem(value: 'price_asc',  child: Text('Price ↑')),
                                        DropdownMenuItem(value: 'price_desc', child: Text('Price ↓')),
                                        DropdownMenuItem(value: 'capacity',   child: Text('Capacity')),
                                      ],
                                      onChanged: (v) {
                                        if (v != null) { setState(() => _sortBy = v); _applyFilter(); }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Result count
                          Text(
                            '${_filtered.length} purifier${_filtered.length != 1 ? 's' : ''} found',
                            style: const TextStyle(fontSize: 12, color: _ink2, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  // ── GRID ─────────────────────────────────────────────
                  if (_filtered.isEmpty)
                    const SliverToBoxAdapter(child: _EmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: _buildGrid(),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final width = MediaQuery.of(context).size.width;
    final crossCount = width >= 900 ? 3 : (width >= 600 ? 2 : 2);

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final m = _filtered[i];
          final accent = _cardAccents[i % _cardAccents.length];
          return _PurifierCard(
            model: m,
            accentColor: accent,
            isRequesting: _requestingId == m.id,
            isDisabled: _requestingId != null,
            onRequest: _request,
            onTap: () => _openDetail(m, accent),
          );
        },
        childCount: _filtered.length,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: crossCount == 2 ? 0.62 : 0.68,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER PILL
// ─────────────────────────────────────────────────────────────────────────────
class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterPill({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: active ? _darkPill : _white,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? _white : _ink2,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO
// ─────────────────────────────────────────────────────────────────────────────
class _CatalogHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 180,
        decoration: BoxDecoration(color: _darkPill, borderRadius: BorderRadius.circular(30)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(top: -30, right: -20,
              child: Container(width: 140, height: 140,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _sky.withValues(alpha: 0.18)))),
            Positioned(bottom: -20, right: 60,
              child: Container(width: 90, height: 90,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _mint.withValues(alpha: 0.15)))),
            Positioned(left: -20, top: 20,
              child: Container(width: 70, height: 70,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _peach.withValues(alpha: 0.12)))),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: _sky, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        const Text('Purifier Catalog', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _sky)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Choose Your\nPurifier',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: _white, height: 1.1, letterSpacing: -1)),
                  const Spacer(),
                  Row(children: [
                    _HeroPill(label: '💧 Water Purifiers', color: _sky),
                    const SizedBox(width: 8),
                    _HeroPill(label: '✅ Free Service', color: _mint),
                  ]),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PURIFIER CARD — image on top
// ─────────────────────────────────────────────────────────────────────────────
class _PurifierCard extends StatefulWidget {
  final PurifierModel model;
  final Color accentColor;
  final bool isRequesting;
  final bool isDisabled;
  final ValueChanged<int> onRequest;
  final VoidCallback onTap;

  const _PurifierCard({
    required this.model,
    required this.accentColor,
    required this.isRequesting,
    required this.isDisabled,
    required this.onRequest,
    required this.onTap,
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
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        transform: Matrix4.identity()
          ..scaleByVector3(vm.Vector3.all(_pressed ? 0.97 : 1.0)),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent.withValues(alpha: 0.6), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product Image ──────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
              child: Container(
                height: 150,
                width: double.infinity,
                color: accent.withValues(alpha: 0.25),
                child: m.imageUrl != null && m.imageUrl!.isNotEmpty
                    ? Image.network(
                        m.imageUrl!,
                        fit: BoxFit.contain,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: accent,
                              strokeWidth: 2,
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text('💧', style: TextStyle(fontSize: 48)),
                        ),
                      )
                    : const Center(child: Text('💧', style: TextStyle(fontSize: 48))),
              ),
            ),

            // ── Body ───────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(m.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: _ink, letterSpacing: -0.3)),
                    const SizedBox(height: 2),
                    // Category
                    if (m.category != null)
                      Text(m.category!,
                          style: const TextStyle(fontSize: 10, color: _ink2,
                              fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),

                    // Chips
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (m.capacity != null)
                          _Chip(label: m.capacity!, bg: _sky.withValues(alpha: 0.35), textColor: const Color(0xFF1A5F7A)),
                        _Chip(label: '${m.freeServices} svc free', bg: _mint.withValues(alpha: 0.45), textColor: const Color(0xFF1A5F3A)),
                        _Chip(label: 'Every ${m.serviceIntervalDays}d', bg: _peach.withValues(alpha: 0.45), textColor: const Color(0xFF7A4A1A)),
                      ],
                    ),

                    const Spacer(),

                    // Price + Request
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Price', style: TextStyle(fontSize: 9, color: _ink2, fontWeight: FontWeight.w500)),
                            Text(
                              m.price != null ? '₹${m.price!.toStringAsFixed(0)}' : '—',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _ink),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: widget.isDisabled ? null : () => widget.onRequest(m.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: widget.isDisabled ? _ink.withValues(alpha: 0.1) : _darkPill,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: widget.isRequesting
                                ? const SizedBox(width: 16, height: 16,
                                    child: CircularProgressIndicator(color: _white, strokeWidth: 2))
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_rounded, size: 14,
                                          color: widget.isDisabled ? _ink2 : _white),
                                      const SizedBox(width: 4),
                                      Text('Request',
                                          style: TextStyle(
                                              fontSize: 11, fontWeight: FontWeight.w700,
                                              color: widget.isDisabled ? _ink2 : _white)),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
// CHIP
// ─────────────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;
  const _Chip({required this.label, required this.bg, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: textColor)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT DETAIL BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _ProductDetailSheet extends StatelessWidget {
  final PurifierModel model;
  final Color accent;
  final int? requestingId;
  final ValueChanged<int> onRequest;

  const _ProductDetailSheet({
    required this.model,
    required this.accent,
    required this.requestingId,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final m = model;
    final featureLines = (m.features ?? '').split('\n').where((l) => l.trim().isNotEmpty).toList();
    final colours = (m.colours ?? '').split(',').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
    final isRequesting = requestingId == m.id;
    final isDisabled = requestingId != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: _ink.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Product Image ──────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  height: 240,
                  width: double.infinity,
                  color: accent.withValues(alpha: 0.3),
                  child: m.imageUrl != null && m.imageUrl!.isNotEmpty
                      ? Image.network(
                          m.imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Text('💧', style: TextStyle(fontSize: 64))),
                        )
                      : const Center(child: Text('💧', style: TextStyle(fontSize: 64))),
                ),
              ),
              const SizedBox(height: 20),

              // ── Name + Category ────────────────────────────────────
              Text(m.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                      color: _ink, letterSpacing: -0.8)),
              const SizedBox(height: 4),
              Row(children: [
                if (m.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(m.category!.toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _ink2, letterSpacing: 0.5)),
                  ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(100)),
                  child: Text('Model #${m.id}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _ink2)),
                ),
              ]),
              const SizedBox(height: 20),

              // ── Stats grid ─────────────────────────────────────────
              Row(children: [
                Expanded(child: _DetailStat(emoji: '💰', label: 'Price',
                    value: m.price != null ? '₹${m.price!.toStringAsFixed(0)}' : '—', bg: _lavender.withValues(alpha: 0.4))),
                const SizedBox(width: 10),
                Expanded(child: _DetailStat(emoji: '🪣', label: 'Capacity',
                    value: m.capacity ?? '—', bg: _sky.withValues(alpha: 0.4))),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _DetailStat(emoji: '✅', label: 'Free Services',
                    value: '${m.freeServices}', bg: _mint.withValues(alpha: 0.4))),
                const SizedBox(width: 10),
                Expanded(child: _DetailStat(emoji: '📅', label: 'Service Interval',
                    value: '${m.serviceIntervalDays} days', bg: _peach.withValues(alpha: 0.4))),
              ]),
              const SizedBox(height: 20),

              // ── Specifications ─────────────────────────────────────
              if (featureLines.isNotEmpty) ...[
                const Text('Specifications',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _ink, letterSpacing: -0.3)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: featureLines.map((line) {
                      final parts = line.split(':');
                      final key = parts.first.trim();
                      final val = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _ink2)),
                            const Spacer(),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(val,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _ink)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Colours ────────────────────────────────────────────
              if (colours.isNotEmpty) ...[
                const Text('Available Colours',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _ink, letterSpacing: -0.3)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colours.map((c) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: _ink.withValues(alpha: 0.08)),
                    ),
                    child: Text(c, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _ink2)),
                  )).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // ── Description ────────────────────────────────────────
              if (m.descriptions != null && m.descriptions!.isNotEmpty) ...[
                const Text('Description',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _ink, letterSpacing: -0.3)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: _white, borderRadius: BorderRadius.circular(18)),
                  child: Text(m.descriptions!,
                      style: const TextStyle(fontSize: 13, color: _ink2, height: 1.5)),
                ),
                const SizedBox(height: 24),
              ],

              // ── CTA ────────────────────────────────────────────────
              GestureDetector(
                onTap: isDisabled ? null : () {
                  Navigator.pop(context);
                  onRequest(m.id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  height: 54,
                  decoration: BoxDecoration(
                    color: isDisabled ? _ink.withValues(alpha: 0.1) : _darkPill,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: isRequesting
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: _white, strokeWidth: 2.5))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline_rounded, size: 18,
                                color: isDisabled ? _ink2 : _white),
                            const SizedBox(width: 8),
                            Text('Request Purifier',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700,
                                    color: isDisabled ? _ink2 : _white)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL STAT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _DetailStat extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color bg;
  const _DetailStat({required this.emoji, required this.label, required this.value, required this.bg});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _ink, height: 1)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _ink2)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADING
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
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
              child: CircularProgressIndicator(color: _darkPill, strokeWidth: 3),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Loading purifiers…',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _ink2)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    debugPrint('Catalog error: $error');
    return ErrorStateCard(
      title: 'Failed to load products',
      message: 'You need to be logged in to view products. Please log in and try again.',
      onRetry: onRetry,
      onLogin: () => Navigator.of(context).pushNamed('/login'),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY
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
              decoration: BoxDecoration(color: _white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
              child: const Center(child: Text('💧', style: TextStyle(fontSize: 28))),
            ),
            const SizedBox(height: 16),
            const Text('No purifiers found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
            const SizedBox(height: 6),
            const Text('Try adjusting your search or filters',
                style: TextStyle(fontSize: 12, color: _ink2)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANON REQUEST SHEET (unchanged, kept for compatibility)
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
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _lavender.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              const Text('📦', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Request Product',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
                Text('Enter your details below',
                    style: TextStyle(fontSize: 11, color: _ink2)),
              ]),
            ]),
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
              onTap: _loading ? null : () async {
                if (_phoneCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('All fields required',
                        style: TextStyle(color: _ink, fontWeight: FontWeight.w600)),
                    backgroundColor: _peach,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ));
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Request error: $e',
                        style: const TextStyle(color: _ink, fontWeight: FontWeight.w600)),
                    backgroundColor: _blush,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ));
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
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(color: _white, strokeWidth: 2.5))
                    : const Text('Submit Request',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}