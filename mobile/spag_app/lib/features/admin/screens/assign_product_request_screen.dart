import 'package:flutter/material.dart';
import '../services/admin_service.dart';

// ─── COLOUR TOKENS (exact web UI) ────────────────────────
// bg:#F5F9FF  panel:#FFFFFF  surface:#EAF3FF
// accent:#2A8FD4  mid:#5AABDE  soft:#C4DFF5
// text:#0D2A3F  muted:#6B8FA8  hairline:#D6E8F5

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

  static const _bg       = Color(0xFFF5F9FF);
  static const _panel    = Color(0xFFFFFFFF);
  static const _surface  = Color(0xFFEAF3FF);
  static const _accent   = Color(0xFF2A8FD4);
  static const _soft     = Color(0xFFC4DFF5);
  static const _text     = Color(0xFF0D2A3F);
  static const _muted    = Color(0xFF6B8FA8);
  static const _hairline = Color(0xFFD6E8F5);

  @override
  void dispose() {
    _technicianIdController.dispose();
    super.dispose();
  }

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
      backgroundColor: _bg,

      // ── App Bar ───────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: _bg,
        elevation: 0,
        foregroundColor: _text,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 14, color: _text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('ADMIN PANEL',
                style: TextStyle(
                  fontSize: 7, fontWeight: FontWeight.w700,
                  color: _muted, letterSpacing: 2.2, fontFamily: 'monospace',
                )),
            Text('Assign Technician',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: _text, letterSpacing: -0.2,
                )),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _hairline),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Request ID hero banner ──────────────────────
            // mirrors ShowcaseCard image panel + stats layout
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A8FD4), Color(0xFF1A6BA8)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(0.16),
                    blurRadius: 14, offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon box — mirrors admin tile icon style
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.16)),
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_rounded,
                      color: Colors.white, size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Eyebrow — mirrors "PURIFICATION SYSTEM" label
                      const Text('PRODUCT REQUEST',
                          style: TextStyle(
                            fontSize: 7, fontWeight: FontWeight.w700,
                            color: Colors.white60, letterSpacing: 2.4,
                            fontFamily: 'monospace',
                          )),
                      const SizedBox(height: 3),
                      Text('#${widget.requestId}',
                          style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w700,
                            color: Colors.white, letterSpacing: -1.0,
                          )),
                    ],
                  ),
                  const Spacer(),
                  // Status pill — mirrors web stats "Grade / Pro" chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: const Text('OPEN',
                        style: TextStyle(
                          fontSize: 7, fontWeight: FontWeight.w700,
                          color: Colors.white, letterSpacing: 1.8,
                          fontFamily: 'monospace',
                        )),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Section eyebrow ─────────────────────────────
            const Text('TECHNICIAN ASSIGNMENT',
                style: TextStyle(
                  fontSize: 7, fontWeight: FontWeight.w700,
                  color: _muted, letterSpacing: 2.4, fontFamily: 'monospace',
                )),
            const SizedBox(height: 4),
            const Text(
              'Enter the technician ID to assign them to this request',
              style: TextStyle(
                fontSize: 11, color: _muted,
                fontFamily: 'monospace', height: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            // ── Input card ──────────────────────────────────
            // mirrors LoginScreen input card style
            Container(
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: _hairline),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(0.04),
                    blurRadius: 8, offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Field label row — mirrors LoginScreen "MOBILE NUMBER"
                  Row(children: [
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _soft),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: _accent, size: 15,
                      ),
                    ),
                    const SizedBox(width: 9),
                    const Text('TECHNICIAN ID',
                        style: TextStyle(
                          fontSize: 8, fontWeight: FontWeight.w700,
                          color: _muted, letterSpacing: 1.8,
                          fontFamily: 'monospace',
                        )),
                  ]),
                  const SizedBox(height: 9),

                  // Text field — mirrors _AquaTextField / _AquaField style
                  TextField(
                    controller: _technicianIdController,
                    keyboardType: TextInputType.number,
                    enabled: !_isAssigning,
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: _text,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter technician ID (e.g. 12345)',
                      hintStyle: const TextStyle(
                        fontSize: 11, color: _muted, fontFamily: 'monospace',
                      ),
                      filled: true,
                      fillColor: _surface,
                      prefixIcon: const Icon(
                        Icons.badge_outlined, color: _accent, size: 16,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _hairline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF5AABDE), width: 1.5,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _hairline),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Info hint box ───────────────────────────────
            // mirrors ProfileTab hint row / LoginScreen hint box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _hairline),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded, size: 12, color: _muted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Make sure the technician ID is valid before assigning',
                    style: TextStyle(
                      fontSize: 10, color: _muted,
                      fontFamily: 'monospace', letterSpacing: 0.2, height: 1.4,
                    ),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 14),

            // ── Assign button ───────────────────────────────
            // mirrors catalog / login CTA button style
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _isAssigning ? null : _assignTechnician,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _soft,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isAssigning
                    ? const SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add_rounded, size: 15),
                          SizedBox(width: 8),
                          Text('ASSIGN TECHNICIAN',
                              style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w700,
                                letterSpacing: 1.8, fontFamily: 'monospace',
                              )),
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