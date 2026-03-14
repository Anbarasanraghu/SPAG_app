import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'customer_catalog_screen.dart';
import 'product_selection_screen.dart';
import 'my_requests_screen.dart';
import 'profile_tab.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../technician/screens/technician_home_screen.dart';
import 'customer_dashboard_screen.dart';

// ─── PALETTE (matches app) ────────────────────────────────────────────────────
const _bg       = Color(0xFFF5F4F0);
const _white    = Color(0xFFFFFFFF);
const _ink      = Color(0xFF111110);
const _ink2     = Color(0xFF8A8880);
const _darkPill = Color(0xFF1A1A18);
const _lavender = Color(0xFFD5CCFF);
const _mint     = Color(0xFFBDF0D8);
const _sky      = Color(0xFFBFE0F5);
const _peach    = Color(0xFFF8DBBF);

// ─────────────────────────────────────────────────────────────────────────────
class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _currentIndex = 0;
  String? role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    role = await AuthService.getRole();
    if (mounted) setState(() {});
  }

  List<Widget> get _pages => <Widget>[
    const ProductSelectionScreen(),
    const MyRequestsScreen(),
    const ProfileTab(),
  ];

  // Nav items config
  static const _navItems = [
    _NavItem(icon: Icons.home_rounded,        label: 'Products', color: _lavender),
    _NavItem(icon: Icons.list_alt_rounded,    label: 'Requests', color: _mint),
    _NavItem(icon: Icons.person_rounded,      label: 'Profile',  color: _peach),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: _bg,
      extendBody: true, // ✅ lets content go behind floating navbar
      appBar: _buildAppBar(),
      body: _pages[_currentIndex],
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final titles = ['Products', 'My Requests', 'Profile'];

    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // App logo / name pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: _darkPill,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: _mint, shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
                const Text(
                  'SPAG',
                  style: TextStyle(
                    color: _white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Page title
          Text(
            titles[_currentIndex],
            style: const TextStyle(
              color: _ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        if (role == null) ...[
          // Not logged in — show Login button
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          // Logged in — show dashboard icon button
          GestureDetector(
            onTap: _goToDashboard,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _sky.withOpacity(0.5),
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
      ],
    );
  }

  Widget _buildHeaderAction() {
    if (role == null) {
      return TextButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        ),
        icon: const Icon(Icons.login, size: 18, color: Color(0xFF2A8FD4)),
        label: Text(
          'LOGIN',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2A8FD4),
          ),
        ),
      );
    }
    
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF2A8FD4).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.dashboard_rounded, size: 20, color: Color(0xFF2A8FD4)),
      ),
      onPressed: _goToDashboard,
    );
  }

  void _goToDashboard() {
    Widget dashboard;
    final r = role?.toLowerCase();
    
    if (r == 'admin') {
      dashboard = const AdminDashboardScreen();
    } else if (r == 'technician') {
      dashboard = const TechnicianHomeScreen();
    } else {
      dashboard = const CustomerDashboardScreen();
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => dashboard),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAV ITEM DATA
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  final Color color;
  const _NavItem({required this.icon, required this.label, required this.color});
}

// ─────────────────────────────────────────────────────────────────────────────
// FLOATING PILL NAVBAR
// ─────────────────────────────────────────────────────────────────────────────
class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: _darkPill,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final item = items[i];
            final isSelected = i == currentIndex;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? item.color.withOpacity(0.22)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      color: isSelected ? item.color : _ink2,
                      size: 22,
                    ),
                    // ✅ Label slides in when selected
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: isSelected
                          ? Row(
                              children: [
                                const SizedBox(width: 7),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    color: item.color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}