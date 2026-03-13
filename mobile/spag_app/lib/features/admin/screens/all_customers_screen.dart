import 'package:flutter/material.dart';
import '../models/admin_customer.dart';
import '../services/admin_customer_service.dart';
import 'customer_detail_screen.dart';

// ─── COLOUR TOKENS (exact web UI) ────────────────────────
// bg:#F5F9FF  panel:#FFFFFF  surface:#EAF3FF
// accent:#2A8FD4  mid:#5AABDE  soft:#C4DFF5
// text:#0D2A3F  muted:#6B8FA8  hairline:#D6E8F5

class AllCustomersScreen extends StatefulWidget {
  const AllCustomersScreen({super.key});

  @override
  State<AllCustomersScreen> createState() => _AllCustomersScreenState();
}

class _AllCustomersScreenState extends State<AllCustomersScreen> {
  bool loading = true;
  List<AdminCustomer> customers = [];

  static const _bg       = Color(0xFFF5F9FF);
  static const _panel    = Color(0xFFFFFFFF);
  static const _surface  = Color(0xFFEAF3FF);
  static const _accent   = Color(0xFF2A8FD4);
  static const _soft     = Color(0xFFC4DFF5);
  static const _text     = Color(0xFF0D2A3F);
  static const _muted    = Color(0xFF6B8FA8);
  static const _hairline = Color(0xFFD6E8F5);

  // Aqua-palette avatar colours — mirrors web hex() map
  static const _avatarColors = [
    Color(0xFF2A8FD4),
    Color(0xFF2A9D6B),
    Color(0xFF7A6FD4),
    Color(0xFFD4842A),
    Color(0xFF5AABDE),
    Color(0xFFD45A8A),
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final data = await AdminCustomerService.fetchCustomers();
      setState(() {
        customers = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.error_outline, color: Colors.white, size: 14),
              SizedBox(width: 8),
              Text('Failed to load customers',
                  style: TextStyle(fontSize: 12, fontFamily: 'monospace')),
            ]),
            backgroundColor: const Color(0xFFE05A5A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          ),
        );
      }
    }
  }

  Color _getAvatarColor(int index) => _avatarColors[index % _avatarColors.length];

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,

      // ── App Bar — dual-line eyebrow pattern ──────────────
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: _bg,
        elevation: 0,
        foregroundColor: _text,
        titleSpacing: 0,
        leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () {
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              },
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
            Text('All Customers',
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

      body: loading

        // ── LOADING ─────────────────────────────────────────
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _panel,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withOpacity(0.10),
                        blurRadius: 14, offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(_accent),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Loading customers...',
                    style: TextStyle(
                      fontSize: 10, color: _muted,
                      fontFamily: 'monospace', letterSpacing: 0.5,
                    )),
              ],
            ),
          )

        // ── EMPTY ────────────────────────────────────────────
        : customers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.people_outline_rounded, size: 36, color: _soft,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('No customers found',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: _text,
                      )),
                  const SizedBox(height: 3),
                  const Text('Customer list is empty',
                      style: TextStyle(
                        fontSize: 10, color: _muted, fontFamily: 'monospace',
                      )),
                ],
              ),
            )

        // ── LIST ─────────────────────────────────────────────
        : Column(
            children: [

              // Stats banner — accent gradient, mirrors hero cards
              Container(
                margin: const EdgeInsets.fromLTRB(11, 11, 11, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_accent, Color(0xFF1A6BA8)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.16),
                      blurRadius: 12, offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: const Icon(
                        Icons.groups_rounded, color: Colors.white, size: 18,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Eyebrow — mirrors "CAPACITY / COLORS / GRADE" labels
                        const Text('TOTAL CUSTOMERS',
                            style: TextStyle(
                              fontSize: 7, fontWeight: FontWeight.w700,
                              color: Colors.white60, letterSpacing: 2.2,
                              fontFamily: 'monospace',
                            )),
                        const SizedBox(height: 2),
                        Text('${customers.length}',
                            style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700,
                              color: Colors.white, letterSpacing: -1.0,
                            )),
                      ],
                    ),
                    const Spacer(),
                    // Grade-style pill — mirrors web stats "Pro" chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.white.withOpacity(0.18)),
                      ),
                      child: const Text('PRO',
                          style: TextStyle(
                            fontSize: 7, fontWeight: FontWeight.w700,
                            color: Colors.white, letterSpacing: 1.8,
                            fontFamily: 'monospace',
                          )),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Section eyebrow — mirrors "AVAILABLE MODELS" / "CUSTOMERS"
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 11),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('CUSTOMERS',
                      style: TextStyle(
                        fontSize: 7, fontWeight: FontWeight.w700,
                        color: _muted, letterSpacing: 2.4,
                        fontFamily: 'monospace',
                      )),
                ),
              ),
              const SizedBox(height: 7),

              // Customer list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(11, 0, 11, 20),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final c     = customers[index];
                    final color = _getAvatarColor(index);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: _hairline),
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withOpacity(0.04),
                            blurRadius: 7, offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(11),
                          splashColor: color.withOpacity(0.06),
                          highlightColor: color.withOpacity(0.03),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CustomerDetailScreen(customerId: c.customerId),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 9),
                            child: Row(
                              children: [

                                // Avatar — initials in tinted rounded box
                                // mirrors NavRail thumb style
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.11),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getInitials(c.name),
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Info column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.name,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: _text,
                                            letterSpacing: -0.1,
                                          )),
                                      const SizedBox(height: 4),

                                      // Phone row
                                      Row(children: [
                                        Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2A9D6B)
                                                .withOpacity(0.10),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Icon(
                                            Icons.phone_rounded,
                                            size: 9,
                                            color: Color(0xFF2A9D6B),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(c.phone,
                                              style: const TextStyle(
                                                fontSize: 10, color: _muted,
                                                fontFamily: 'monospace',
                                              )),
                                        ),
                                      ]),
                                      const SizedBox(height: 3),

                                      // Address row
                                      Row(children: [
                                        Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: _accent.withOpacity(0.10),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Icon(
                                            Icons.location_on_rounded,
                                            size: 9, color: _accent,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(c.address,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 10, color: _muted,
                                                fontFamily: 'monospace',
                                              )),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),

                                // Arrow chip — mirrors web arrow_forward_ios chip
                                Container(
                                  width: 22, height: 22,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: color, size: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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