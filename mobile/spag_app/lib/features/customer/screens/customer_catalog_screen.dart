import 'package:flutter/material.dart';
import '../../../core/models/purifier_model.dart';
import '../../../core/api/purifier_service.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/controller/auth_controller.dart';
import 'customer_home_decider_screen.dart';

// ─── COLOUR TOKENS ───────────────────────────────────────
// bg: #F5F9FF  panels: #FFFFFF  surface: #EAF3FF
// accent: #2A8FD4  mid: #5AABDE  soft: #C4DFF5
// text: #0D2A3F  muted: #6B8FA8  hairline: #D6E8F5

class CustomerCatalogScreen extends StatefulWidget {
  const CustomerCatalogScreen({super.key});

  @override
  State<CustomerCatalogScreen> createState() => _CustomerCatalogScreenState();
}

class _CustomerCatalogScreenState extends State<CustomerCatalogScreen> {
  late Future<List<PurifierModel>> _modelsFuture;
  int? _requestingId;

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

    _modelsFuture = PurifierService.listModels().then((models) {
      debugPrint("[CustomerCatalog] Loaded ${models.length} models");
      return models;
    }).catchError((e) {
      debugPrint("[CustomerCatalog] Error loading models: $e");
      throw e;
    });
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
          builder: (context) {
            final phoneCtrl = TextEditingController();
            final emailCtrl = TextEditingController();
            final passCtrl  = TextEditingController();
            bool loading    = false;

            return StatefulBuilder(builder: (context, setState) {
              return Container(
                decoration: const BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 36,
                          height: 3,
                          decoration: BoxDecoration(
                            color: _soft,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'REQUEST PRODUCT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _muted,
                          letterSpacing: 2.0,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Enter your details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _text,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _AquaTextField(controller: phoneCtrl, label: 'Mobile Number', keyboardType: TextInputType.phone),
                      const SizedBox(height: 8),
                      _AquaTextField(controller: emailCtrl, label: 'Gmail', keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 8),
                      _AquaTextField(controller: passCtrl, label: 'Password', obscureText: true),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: loading
                              ? null
                              : () async {
                                  if (phoneCtrl.text.trim().isEmpty ||
                                      emailCtrl.text.trim().isEmpty ||
                                      passCtrl.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('All fields required')),
                                    );
                                    return;
                                  }
                                  setState(() => loading = true);
                                  try {
                                    await PurifierService.requestProduct(
                                      id,
                                      mobile: phoneCtrl.text.trim(),
                                      gmail: emailCtrl.text.trim(),
                                      password: passCtrl.text,
                                    );
                                    Navigator.pop(context, {'success': 'true'});
                                  } catch (e) {
                                    setState(() => loading = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Request error: $e')),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'SUBMIT REQUEST',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.0,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        );

        if (result?['success'] != 'true') return;
      } else {
        await PurifierService.requestProduct(id);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 16),
              SizedBox(width: 10),
              Text('Request submitted successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF2A8FD4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                const Icon(Icons.error_outline, color: Colors.white, size: 16),
                const SizedBox(width: 10),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _requestingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          // ── APP BAR ────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PURIFICATION SYSTEM',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 2.0,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Choose Your Purifier',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_accent, Color(0xFF1A6BA8)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -40,
                      top: -40,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── CONTENT ────────────────────────────────────────
          SliverToBoxAdapter(
            child: FutureBuilder<List<PurifierModel>>(
              future: _modelsFuture,
              builder: (context, snapshot) {
                // ── LOADING ──
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height - 160,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: _panel,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _accent.withOpacity(0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(_accent),
                              strokeWidth: 2.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Loading purifiers...',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'monospace',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ── ERROR ──
                if (snapshot.hasError) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height - 160,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F0),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.error_outline, size: 40, color: Color(0xFFE05A5A)),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Failed to load purifiers',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _text,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: _muted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final models = snapshot.data ?? [];

                // ── EMPTY ──
                if (models.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height - 160,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: _surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.water_drop_outlined, size: 40, color: _soft),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'No purifiers available',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Please check back later',
                            style: TextStyle(fontSize: 12, color: _muted),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ── LIST ──
                return Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header
                      const Text(
                        'AVAILABLE MODELS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _muted,
                          letterSpacing: 2.2,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Select the perfect purifier for your needs',
                        style: TextStyle(
                          fontSize: 12,
                          color: _muted,
                        ),
                      ),
                      const SizedBox(height: 14),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: models.length,
                        itemBuilder: (context, index) {
                          final m = models[index];
                          final isRequesting = _requestingId == m.id;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _accent.withOpacity(0.07),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _panel,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _hairline, width: 1),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [_panel, Color(0xFFF0F8FF)],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── Header row ──
                                    Row(
                                      children: [
                                        // Icon box
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [_accent, Color(0xFF1A6BA8)],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _accent.withOpacity(0.25),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.water_drop,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                m.name,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: _text,
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _surface,
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: _soft, width: 1),
                                                ),
                                                child: Text(
                                                  'Model #${m.id}',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: _accent,
                                                    fontFamily: 'monospace',
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // ── Stats row ──
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: _surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: _hairline, width: 1),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _InfoChip(
                                              icon: Icons.build_circle_outlined,
                                              label: 'Free Services',
                                              value: '${m.freeServices}',
                                              color: const Color(0xFF2A9D6B),
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 36,
                                            color: _hairline,
                                            margin: const EdgeInsets.symmetric(horizontal: 10),
                                          ),
                                          Expanded(
                                            child: _InfoChip(
                                              icon: Icons.calendar_today,
                                              label: 'Service Interval',
                                              value: '${m.serviceIntervalDays}d',
                                              color: const Color(0xFFD4842A),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // ── CTA Button ──
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: ElevatedButton(
                                        onPressed: isRequesting || _requestingId != null
                                            ? null
                                            : () => _request(m.id),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _accent,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor: _hairline,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: isRequesting
                                            ? const SizedBox(
                                                height: 18,
                                                width: 18,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.check_circle_outline, size: 16),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'REQUEST THIS PURIFIER',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700,
                                                      letterSpacing: 1.8,
                                                      fontFamily: 'monospace',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AQUA TEXT FIELD ─────────────────────────────────────
class _AquaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;

  const _AquaTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 13, color: Color(0xFF0D2A3F)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 11,
          color: Color(0xFF6B8FA8),
          fontFamily: 'monospace',
          letterSpacing: 0.3,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F9FF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD6E8F5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF5AABDE), width: 1.5),
        ),
      ),
    );
  }
}

// ─── INFO CHIP ────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFF6B8FA8),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            fontFamily: 'monospace',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}