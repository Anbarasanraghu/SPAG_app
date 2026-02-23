import 'package:flutter/material.dart';
import 'product_requests_screen.dart';
import 'pending_services_screen.dart';
import 'manage_users_screen.dart';
import 'service_status_logs_screen.dart';
import 'technician_activity_logs_screen.dart';
import 'all_customers_screen.dart';

// ─── COLOUR TOKENS ───────────────────────────────────────
// bg: #F5F9FF  panels: #FFFFFF  surface: #EAF3FF
// accent: #2A8FD4  mid: #5AABDE  soft: #C4DFF5
// text: #0D2A3F  muted: #6B8FA8  hairline: #D6E8F5

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const Color _bg       = Color(0xFFF5F9FF);
  static const Color _panel    = Color(0xFFFFFFFF);
  static const Color _surface  = Color(0xFFEAF3FF);
  static const Color _accent   = Color(0xFF2A8FD4);
  static const Color _text     = Color(0xFF0D2A3F);
  static const Color _muted    = Color(0xFF6B8FA8);
  static const Color _hairline = Color(0xFFD6E8F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        surfaceTintColor: _bg,
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: _text,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'ADMIN PANEL',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: _muted,
                letterSpacing: 2.2,
                fontFamily: 'monospace',
              ),
            ),
            SizedBox(height: 1),
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _text,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _hairline),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
        children: [

          // ── Hero banner ────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_accent, Color(0xFF1A6BA8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _accent.withOpacity(0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CONTROL CENTER',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Manage your business efficiently',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Section label ──────────────────────────────────
          const Text(
            'QUICK ACCESS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: _muted,
              letterSpacing: 2.2,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 10),

          // ── Tiles ──────────────────────────────────────────
          _adminTile(
            context,
            title: 'Manage Users & Roles',
            subtitle: 'Control user access and permissions',
            icon: Icons.people_outline_rounded,
            color: const Color(0xFF2A9D6B),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
            ),
          ),
          _adminTile(
            context,
            title: 'Service Status Logs',
            subtitle: 'View status change history for all services',
            icon: Icons.history_toggle_off_rounded,
            color: _accent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ServiceStatusLogsScreen()),
            ),
          ),
          _adminTile(
            context,
            title: 'Technician Activity Logs',
            subtitle: 'View actions performed by all technicians',
            icon: Icons.timeline_rounded,
            color: const Color(0xFF5AABDE),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TechnicianActivityLogsScreen()),
            ),
          ),
          _adminTile(
            context,
            title: 'Pending Services',
            subtitle: 'Review and manage pending tasks',
            icon: Icons.pending_actions_outlined,
            color: const Color(0xFFD4842A),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PendingServicesScreen()),
            ),
          ),
          _adminTile(
            context,
            title: 'All Customers',
            subtitle: 'View and manage customer data',
            icon: Icons.groups_outlined,
            color: const Color(0xFF7A6FD4),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllCustomersScreen()),
            ),
          ),
          _adminTile(
            context,
            title: 'Product Requests',
            subtitle: 'Handle customer product requests',
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFFD45A8A),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductRequestsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _hairline),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: color.withOpacity(0.06),
          highlightColor: color.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                // Icon box
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _text,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: _muted,
                          fontFamily: 'monospace',
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(Icons.arrow_forward_ios_rounded, color: color, size: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}