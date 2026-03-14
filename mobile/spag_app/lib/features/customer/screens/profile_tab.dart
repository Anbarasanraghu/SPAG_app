import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../../../core/ui/ui_kit.dart';
import '../../auth/services/auth_service.dart';
import '../../customer/services/customer_profile_service.dart';
import '../screens/customer_dashboard_screen.dart';
import '../../auth/controller/auth_controller.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../technician/screens/technician_home_screen.dart';
import '../../auth/screens/login_screen.dart';

// ─── COLOUR TOKENS ───────────────────────────────────────
// bg: #F5F9FF  panels: #FFFFFF  surface: #EAF3FF
// accent: #2A8FD4  mid: #5AABDE  soft: #C4DFF5
// text: #0D2A3F  muted: #6B8FA8  hairline: #D6E8F5

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _loading = true;
  String? _token;
  String? _role;
  final _authController = AuthController();

  // ─── PALETTE ───────────────────────────────────────────────────────────────
  static const _bg = Color(0xFFF5F4F0);
  static const _dark = Color(0xFF1A1A18);
  static const _lavender = Color(0xFFD5CCFF);
  static const _mint = Color(0xFFBDF0D8);
  static const _peach = Color(0xFFF8DBBF);
  static const _blush = Color(0xFFF5C8D4);
  static const _ink = Color(0xFF111110);
  static const _ink2 = Color(0xFF8A8880);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final token = await AuthService.getToken();
    final role = await AuthService.getRole();
    setState(() {
      _token = token;
      _role = role?.toLowerCase().trim();
      _loading = false;
    });
  }

  Future<void> _goToDashboard() async {
    if (_token == null) return;
    if (_role == 'admin') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
    } else if (_role == 'technician') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const TechnicianHomeScreen()));
    } else {
      final exists = await CustomerProfileService.profileExists();
      if (!mounted) return;
      if (!exists) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Installation Pending'),
            content: const Text(
                'Your installation is pending. Please wait for technician.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              )
            ],
          ),
        );
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()));
      }
    }
  }

  Future<void> _showLogin() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => LoginScreen()));
    if (result is AuthResponse) {
      await AuthService.saveRole(result.role);
      setState(() {
        _token = result.token;
        _role = result.role.toLowerCase().trim();
      });
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    setState(() {
      _token = null;
      _role = null;
    });
  }

  String get _roleLabel {
    switch (_role) {
      case 'admin':
        return 'Administrator';
      case 'technician':
        return 'Technician';
      default:
        return 'Customer';
    }
  }

  String get _roleEmoji {
    switch (_role) {
      case 'admin':
        return '🛡️';
      case 'technician':
        return '⚙️';
      default:
        return '👤';
    }
  }

  Color get _roleColor {
    switch (_role) {
      case 'admin':
        return _blush;
      case 'technician':
        return _mint;
      default:
        return _lavender;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bg,
        bottomNavigationBar: const SpagFooterLogo(),
        body: Center(child: CircularProgressIndicator(color: _dark)),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: const SpagFooterLogo(),
      body: SafeArea(
        child: _token == null ? _buildLoggedOut() : _buildLoggedIn(),
      ),
    );
  }

  // ─── LOGGED OUT ─────────────────────────────────────────────────────────────
  Widget _buildLoggedOut() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _lavender.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👤', style: TextStyle(fontSize: 44)),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Welcome!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Login to access your profile\nand manage your services',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _ink2, height: 1.5),
          ),
          const SizedBox(height: 40),

          // Login button
          _ProfileButton(
            label: 'Login to Account',
            emoji: '🔑',
            color: _dark,
            textColor: Colors.white,
            onTap: _showLogin,
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _peach.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Text('💡', style: TextStyle(fontSize: 18)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Request a product from the Catalog to register as a customer',
                    style: TextStyle(
                        fontSize: 12,
                        color: _ink2,
                        fontWeight: FontWeight.w500,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── LOGGED IN ──────────────────────────────────────────────────────────────
  Widget _buildLoggedIn() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Avatar card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _dark,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _roleColor.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _roleColor.withValues(alpha: 0.5), width: 2),
                  ),
                  child: Center(
                    child: Text(_roleEmoji,
                        style: const TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _roleColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                        color: _roleColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    _roleLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _roleColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Logged In',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Dashboard button
          _ProfileButton(
            label: 'Open Dashboard',
            emoji: '📊',
            color: _roleColor.withValues(alpha: 0.4),
            textColor: _ink,
            onTap: _goToDashboard,
          ),
          const SizedBox(height: 12),

          // Info tiles
          _InfoTile(
            emoji: '🔒',
            label: 'Account Role',
            value: _roleLabel,
            color: _roleColor,
          ),
          const SizedBox(height: 10),
          _InfoTile(
            emoji: '✅',
            label: 'Status',
            value: 'Active',
            color: _mint,
          ),
          const SizedBox(height: 24),

          // Logout button
          _ProfileButton(
            label: 'Logout',
            emoji: '🚪',
            color: _blush.withValues(alpha: 0.4),
            textColor: const Color(0xFFB03050),
            onTap: _logout,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── REUSABLE WIDGETS ─────────────────────────────────────────────────────────
class _ProfileButton extends StatefulWidget {
  final String label;
  final String emoji;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ProfileButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<_ProfileButton> {
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
        transform: Matrix4.identity()..scaleByVector3(vm.Vector3.all(_pressed ? 0.97 : 1.0)),
        transformAlignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: widget.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8A8880))),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111110))),
            ],
          ),
        ],
      ),
    );
  }
}
