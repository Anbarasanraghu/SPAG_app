import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../services/installation_service.dart';
import '../models/installation_job.dart';

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
class InstallationJobsScreen extends StatefulWidget {
  const InstallationJobsScreen({super.key});

  @override
  State<InstallationJobsScreen> createState() =>
      _InstallationJobsScreenState();
}

class _InstallationJobsScreenState extends State<InstallationJobsScreen> {
  late Future<List<InstallationJob>> futureJobs;

  @override
  void initState() {
    super.initState();
    futureJobs = InstallationService.fetchInstallations();
  }

  void refresh() {
    setState(() {
      futureJobs = InstallationService.fetchInstallations();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: FutureBuilder<List<InstallationJob>>(
          future: futureJobs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingState();
            }
            if (snapshot.hasError) {
              return _ErrorState(
                error: snapshot.error.toString(),
                onRetry: refresh,
              );
            }
            final jobs = snapshot.data ?? [];
            if (jobs.isEmpty) {
              return _EmptyState(onRefresh: refresh);
            }

            return RefreshIndicator(
              color: _darkPill,
              backgroundColor: _white,
              onRefresh: () async => refresh(),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: _HeroHeader(jobCount: jobs.length),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _JobCard(
                            job: jobs[index],
                            index: index,
                            onComplete: () =>
                                _completeInstallation(jobs[index]),
                          ),
                        ),
                        childCount: jobs.length,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Input field ───────────────────────────────────────────────────────────
  Widget _inputField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: _white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: _ink),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
                fontSize: 12, color: _ink2, fontWeight: FontWeight.w500),
            prefixIcon:
                icon != null ? Icon(icon, size: 18, color: _ink2) : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 13),
          ),
        ),
      ),
    );
  }

  // ─── Bottom sheet form ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> _showCompletionForm(
      InstallationJob job) async {
    final nameCtrl     = TextEditingController(text: job.customerName);
    final phoneCtrl    = TextEditingController(text: job.customerPhone);
    final addressCtrl  = TextEditingController(text: job.address);
    final cityCtrl     = TextEditingController();
    final stateCtrl    = TextEditingController();
    final pincodeCtrl  = TextEditingController();
    final landmarkCtrl = TextEditingController();
    final dateCtrl     = TextEditingController(
        text: DateTime.now().toIso8601String().split('T').first);
    final siteNotesCtrl = TextEditingController();

    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.97,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: _bg,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _ink.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _mint.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text('🔧',
                              style: TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Complete Installation',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: _ink,
                                    letterSpacing: -0.4),
                              ),
                              Text(
                                job.customerName,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: _ink2,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      children: [
                        _FormSection(
                          label: '👤 Customer Info',
                          color: _sky,
                          children: [
                            _inputField('Customer Name', nameCtrl,
                                icon: Icons.person_outline),
                            _inputField('Phone Number', phoneCtrl,
                                icon: Icons.phone_outlined),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _FormSection(
                          label: '📍 Location',
                          color: _lavender,
                          children: [
                            _inputField('Address', addressCtrl,
                                icon: Icons.home_outlined),
                            _inputField('City', cityCtrl,
                                icon: Icons.location_city_outlined),
                            _inputField('State', stateCtrl,
                                icon: Icons.map_outlined),
                            _inputField('Pincode', pincodeCtrl,
                                icon: Icons.pin_drop_outlined),
                            _inputField('Landmark', landmarkCtrl,
                                icon: Icons.place_outlined),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _FormSection(
                          label: '📅 Installation Details',
                          color: _peach,
                          children: [
                            _inputField('Installation Date', dateCtrl,
                                icon: Icons.date_range_outlined,
                                readOnly: true),
                            _inputField('Site Details / Notes', siteNotesCtrl,
                                icon: Icons.note_outlined, maxLines: 3),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _PillButton(
                          label: 'Submit & Complete',
                          emoji: '✅',
                          onTap: () {
                            Navigator.pop(ctx, {
                              'customer_name': nameCtrl.text,
                              'customer_phone': phoneCtrl.text,
                              'address': addressCtrl.text,
                              'city': cityCtrl.text,
                              'state': stateCtrl.text,
                              'pincode': pincodeCtrl.text,
                              'landmark': landmarkCtrl.text,
                              'installation_date': dateCtrl.text,
                              'site_details': siteNotesCtrl.text,
                            });
                          },
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(ctx).viewInsets.bottom + 16),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Complete installation (unchanged logic) ───────────────────────────────
  Future<void> _completeInstallation(InstallationJob job) async {
    final details = await _showCompletionForm(job);
    if (details == null) return;
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
              Text('Completing installation…',
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
      final payload = {
        ...details,
        'purifier_model_id': job.purifierModelId,
      };
      await InstallationService.completeInstallation(
          job.requestId, job, payload);

      if (!mounted) return;
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Text('✅', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${job.customerName}\'s installation completed!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          backgroundColor: _darkPill,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
      refresh();
    } catch (e) {
      if (!mounted) return;
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Text('❌', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Error: $e',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ]),
          backgroundColor: const Color(0xFFB03050),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO HEADER — content-sized (no fixed height → no overflow)
// ─────────────────────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final int jobCount;
  const _HeroHeader({required this.jobCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: _darkPill,
          borderRadius: BorderRadius.circular(28),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // decorative circles (overflow clipped by clipBehavior)
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _mint.withValues(alpha: 0.15),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              right: 60,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _lavender.withValues(alpha: 0.12),
                ),
              ),
            ),
            // content — NO fixed height, wraps naturally
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // live badge
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
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: _mint, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$jobCount Jobs Pending',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _mint),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Installation\nJobs',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: _white,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // pills — Wrap prevents horizontal overflow on small screens
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _HeroPill(label: '🔧 Technician', color: _peach),
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
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// JOB CARD
// ─────────────────────────────────────────────────────────────────────────────
class _JobCard extends StatefulWidget {
  final InstallationJob job;
  final int index;
  final VoidCallback onComplete;
  const _JobCard(
      {required this.job, required this.index, required this.onComplete});

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  bool _pressed = false;

  static const _cardColors = [
    _lavender, _mint, _sky, _peach, _blush, _sage,
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _cardColors[widget.index % _cardColors.length];

    return Container(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Text('🏠', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job.customerName.isNotEmpty
                            ? widget.job.customerName
                            : 'Unknown Customer',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: _darkPill.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          widget.job.modelName.isNotEmpty
                              ? widget.job.modelName
                              : '—',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#${widget.index + 1}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _ink2),
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
                color: _ink.withValues(alpha: 0.08), height: 1, thickness: 1),
          ),

          // ── Detail rows ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                _DetailRow(
                  emoji: '📱',
                  label: 'Phone',
                  value: widget.job.customerPhone.isEmpty
                      ? '—'
                      : widget.job.customerPhone,
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  emoji: '📍',
                  label: 'Address',
                  value: widget.job.address.isEmpty
                      ? '—'
                      : widget.job.address,
                ),
              ],
            ),
          ),

          // ── Complete button ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: GestureDetector(
              onTap: widget.onComplete,
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 130),
                height: 50,
                transform: Matrix4.identity()
                  ..scaleByVector3(vm.Vector3.all(_pressed ? 0.97 : 1.0)),
                transformAlignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _pressed
                      ? _darkPill.withValues(alpha: 0.82)
                      : _darkPill,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('✅', style: TextStyle(fontSize: 15)),
                    SizedBox(width: 8),
                    Text(
                      'Complete Installation',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _white,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL ROW
// ─────────────────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  const _DetailRow(
      {required this.emoji, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _ink2)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13,
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
// FORM SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _FormSection extends StatelessWidget {
  final String label;
  final Color color;
  final List<Widget> children;
  const _FormSection(
      {required this.label, required this.color, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _ink2)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PILL BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _PillButton extends StatefulWidget {
  final String label;
  final String emoji;
  final VoidCallback onTap;
  const _PillButton(
      {required this.label, required this.emoji, required this.onTap});

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> {
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
        height: 54,
        transform: Matrix4.identity()..scaleByVector3(vm.Vector3.all(_pressed ? 0.97 : 1.0)),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _pressed ? _darkPill.withValues(alpha: 0.82) : _darkPill,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text(
              widget.label,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _white,
                  letterSpacing: 0.2),
            ),
          ],
        ),
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _darkPill, strokeWidth: 2.5),
          SizedBox(height: 16),
          Text('Loading jobs…',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _ink2)),
        ],
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
    return Center(
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
            const SizedBox(height: 18),
            const Text('Something went wrong',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                    letterSpacing: -0.4)),
            const SizedBox(height: 10),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: _ink2, height: 1.5)),
            const SizedBox(height: 24),
            _PillButton(label: 'Retry', emoji: '🔄', onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: _sage.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Text('🎉', style: TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 18),
            const Text('All Done!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                    letterSpacing: -0.5)),
            const SizedBox(height: 8),
            const Text(
              'No pending installation jobs.\nAll installations are completed!',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 13, color: _ink2, height: 1.6),
            ),
            const SizedBox(height: 24),
            _PillButton(
                label: 'Refresh', emoji: '🔄', onTap: onRefresh),
          ],
        ),
      ),
    );
  }
}
