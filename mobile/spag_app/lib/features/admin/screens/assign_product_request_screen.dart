import 'package:flutter/material.dart';
import '../services/admin_service.dart';

// ─── COLOUR TOKENS — matches AdminDashboard ui_kit ───────────────────────────
const _kBg       = Color(0xFFF5F5F0);
const _kDarkPill = Color(0xFF1E1E2E);
const _kInk      = Color(0xFF1A1A1A);
const _kInk2     = Color(0xFF666666);
const _kWhite    = Color(0xFFFFFFFF);
const _kMint     = Color(0xFF82DCB4);
const _kLavender = Color(0xFFB4A0FF);
const _kPeach    = Color(0xFFFFB48C);
const _kSky      = Color(0xFF8CC8F0);
const _kSage     = Color(0xFF96C8A0);

class AssignProductRequestScreen extends StatefulWidget {
  final int requestId;
  const AssignProductRequestScreen({super.key, required this.requestId});

  @override
  State<AssignProductRequestScreen> createState() =>
      _AssignProductRequestScreenState();
}

class _AssignProductRequestScreenState
    extends State<AssignProductRequestScreen> {
  final _technicianIdController = TextEditingController();
  bool _isAssigning = false;

  @override
  void dispose() {
    _technicianIdController.dispose();
    super.dispose();
  }

  // ── ALL LOGIC UNCHANGED ───────────────────────────────────────────────────
  Future<void> _assignTechnician() async {
    final techId = _technicianIdController.text.trim();

    if (techId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 14),
            SizedBox(width: 8),
            Expanded(child: Text('Please enter a technician ID',
                style: TextStyle(fontSize: 12, fontFamily: 'monospace'))),
          ]),
          backgroundColor: const Color(0xFFD4842A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          margin: const EdgeInsets.all(12),
        ),
      );
      return;
    }

    setState(() => _isAssigning = true);

    try {
      await AdminService.assignProductRequest(
        requestId: widget.requestId,
        technicianUserId: int.parse(techId),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
            SizedBox(width: 8),
            Expanded(child: Text('Technician assigned successfully',
                style: TextStyle(fontSize: 12, fontFamily: 'monospace'))),
          ]),
          backgroundColor: const Color(0xFF2A9D6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          margin: const EdgeInsets.all(12),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 14),
            const SizedBox(width: 8),
            Expanded(child: Text('Failed: $message',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'))),
          ]),
          backgroundColor: const Color(0xFFE05A5A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          margin: const EdgeInsets.all(12),
        ),
      );
    } finally {
      if (mounted) setState(() => _isAssigning = false);
    }
  }

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
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [

            // ── 1. Hero Card — dark pill ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: _kDarkPill,
                  borderRadius: BorderRadius.circular(30),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Decorative circles
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mint badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: _kMint.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  color: _kMint.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6, height: 6,
                                  decoration: const BoxDecoration(
                                      color: _kMint,
                                      shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                const Text('OPEN',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _kMint)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Title
                          const Text(
                            'Assign\nTechnician',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: _kWhite,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                          ),
                          const Spacer(),
                          // Pills
                          Row(
                            children: [
                              _HeroPill(
                                  label:
                                      'Request #${widget.requestId}',
                                  color: _kPeach),
                              const SizedBox(width: 8),
                              _HeroPill(
                                  label: 'Product',
                                  color: _kLavender),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── 2. Section Title ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Technician Assignment',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _kInk,
                          letterSpacing: -0.5)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Enter the technician ID to assign them to this request',
                style: TextStyle(fontSize: 11, color: _kInk2, height: 1.5),
              ),
            ),

            const SizedBox(height: 16),

            // ── 3. Input bento card ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _kLavender.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label row
                    Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: _kWhite.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person_outline_rounded,
                            color: _kInk, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text('TECHNICIAN ID',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _kInk,
                              letterSpacing: 0.5)),
                    ]),
                    const SizedBox(height: 14),

                    // Text field — dashboard-style
                    TextField(
                      controller: _technicianIdController,
                      keyboardType: TextInputType.number,
                      enabled: !_isAssigning,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _kInk),
                      decoration: InputDecoration(
                        hintText: 'e.g. 12345',
                        hintStyle: const TextStyle(
                            fontSize: 12, color: _kInk2),
                        filled: true,
                        fillColor: _kWhite.withValues(alpha: 0.6),
                        prefixIcon: const Icon(Icons.badge_outlined,
                            color: _kInk2, size: 18),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                              color: _kWhite.withValues(alpha: 0.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                              color: _kLavender, width: 1.5),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                              color: _kWhite.withValues(alpha: 0.0)),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── 4. Info hint bento ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _kSky.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: _kWhite.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.info_outline_rounded,
                        size: 16, color: _kInk2),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Make sure the technician ID is valid before assigning',
                      style: TextStyle(
                          fontSize: 11, color: _kInk2, height: 1.4),
                    ),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 20),

            // ── 5. Assign button — bento style ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _isAssigning ? null : _assignTechnician,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isAssigning
                        ? _kSage.withValues(alpha: 0.4)
                        : _kDarkPill,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: _isAssigning
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(
                                color: _kWhite, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.person_add_rounded,
                                  color: _kWhite, size: 18),
                              SizedBox(width: 10),
                              Text('Assign Technician',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: _kWhite,
                                      letterSpacing: -0.3)),
                            ],
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),
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
