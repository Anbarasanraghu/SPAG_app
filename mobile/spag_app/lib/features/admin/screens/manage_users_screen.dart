import 'package:flutter/material.dart';
import '../models/admin_user.dart';
import '../services/admin_user_service.dart';

// ─── COLOUR TOKENS — matches AdminDashboard ui_kit ───────────────────────────
const _kBg       = Color(0xFFF5F5F0);
const _kDarkPill = Color(0xFF1E1E2E);
const _kInk      = Color(0xFF1A1A1A);
const _kInk2     = Color(0xFF666666);
const _kWhite    = Color(0xFFFFFFFF);
const _kMint     = Color(0xFF82DCB4);
const _kLavender = Color(0xFFB4A0FF);
const _kPeach    = Color(0xFFFFB48C);
const _kBlush    = Color(0xFFFFB4BE);
const _kSage     = Color(0xFF96C8A0);
const _kSky      = Color(0xFF8CC8F0);

const _cardColors = [
  Color(0xFFB4A0FF),
  Color(0xFF82DCB4),
  Color(0xFF8CC8F0),
  Color(0xFFFFB48C),
  Color(0xFFFFB4BE),
  Color(0xFF96C8A0),
];

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  late Future<List<AdminUser>> usersFuture;

  // ── LOGIC UNCHANGED ───────────────────────────────────────────────────────
  static const List<String> _validRoles = ['admin', 'technician', 'customer'];

  @override
  void initState() {
    super.initState();
    usersFuture = AdminUserService.fetchUsers();
  }

  String _normalizeRole(String role) {
    final normalized = role.trim().toLowerCase();
    return _validRoles.contains(normalized) ? normalized : 'customer';
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase().trim()) {
      case 'admin':
        return const Color(0xFFEC4899);
      case 'technician':
        return const Color(0xFF3B82F6);
      case 'customer':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase().trim()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'technician':
        return Icons.engineering;
      case 'customer':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }

  Color _cardColor(int i) => _cardColors[i % _cardColors.length];

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
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
        child: FutureBuilder<List<AdminUser>>(
          future: usersFuture,
          builder: (context, snapshot) {

            // ── LOADING ─────────────────────────────────────────────────
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ── ERROR ───────────────────────────────────────────────────
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: _kBlush.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.error_outline,
                            size: 40, color: _kInk2),
                      ),
                      const SizedBox(height: 14),
                      const Text('Something went wrong',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _kInk)),
                      const SizedBox(height: 4),
                      Text(snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 11, color: _kInk2)),
                    ],
                  ),
                ),
              );
            }

            final users = snapshot.data!;

            // ── EMPTY ───────────────────────────────────────────────────
            if (users.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: _kLavender.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.people_outline,
                          size: 40, color: _kInk2),
                    ),
                    const SizedBox(height: 14),
                    const Text('No users found',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _kInk)),
                    const SizedBox(height: 4),
                    const Text('There are no users to display',
                        style: TextStyle(fontSize: 11, color: _kInk2)),
                  ],
                ),
              );
            }

            // ── LIST ────────────────────────────────────────────────────
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [

                // ── Hero Card ──────────────────────────────────────────
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
                                    Text('${users.length} Users',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: _kMint)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Manage\nUsers',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: _kWhite,
                                  height: 1.1,
                                  letterSpacing: -1,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  _HeroPill(
                                      label: '${users.length} Total',
                                      color: _kPeach),
                                  const SizedBox(width: 8),
                                  const _HeroPill(
                                      label: 'Roles & Permissions',
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

                // ── Section Title ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('User Directory',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _kInk,
                              letterSpacing: -0.5)),
                      Text('${users.length} total',
                          style: const TextStyle(
                              fontSize: 12,
                              color: _kInk2,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── User Cards ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: List.generate(users.length, (i) {
                      final user = users[i];
                      final normalizedRole = _normalizeRole(user.role);
                      final roleColor = _getRoleColor(normalizedRole);
                      final roleIcon = _getRoleIcon(normalizedRole);
                      final color = _cardColor(i);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.38),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [

                              // Avatar — initials box
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  color: _kWhite.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Text(
                                    _initials(user.name),
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: _kInk),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // User info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(user.name ?? 'Unknown',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: _kInk,
                                            letterSpacing: -0.3)),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      Container(
                                        width: 18, height: 18,
                                        decoration: BoxDecoration(
                                          color:
                                              _kWhite.withValues(alpha: 0.5),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                            Icons.phone_outlined,
                                            size: 10,
                                            color: _kInk2),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(user.phone,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: _kInk2)),
                                    ]),
                                  ],
                                ),
                              ),

                              // Role Dropdown — logic completely unchanged
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _kWhite.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButton<String>(
                                  value: user.role.toLowerCase().trim(),
                                  underline: const SizedBox(),
                                  isDense: true,
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: roleColor, size: 18),
                                  style: TextStyle(
                                      color: roleColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                  items: _validRoles.map((role) {
                                    return DropdownMenuItem<String>(
                                      value: role,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getRoleIcon(role),
                                            size: 13,
                                            color: _getRoleColor(role),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            role[0].toUpperCase() +
                                                role.substring(1),
                                            style: TextStyle(
                                                color: _getRoleColor(role),
                                                fontSize: 12,
                                                fontWeight:
                                                    FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newRole) async {
                                    if (newRole == null) return;
                                    await AdminUserService.updateUserRole(
                                      userId: user.id,
                                      role: newRole,
                                    );
                                    setState(() {
                                      usersFuture =
                                          AdminUserService.fetchUsers();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            );
          },
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
