import 'package:flutter/material.dart';
import 'customer_catalog_screen.dart';
import 'my_requests_screen.dart';
import 'profile_tab.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../technician/screens/technician_home_screen.dart';
import 'customer_dashboard_screen.dart';

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

  static const List<Widget> _pages = <Widget>[
    CustomerCatalogScreen(),
    MyRequestsScreen(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Removed the standard AppBar to let sub-pages manage their own look, 
      // or used a very slim one if you prefer global control:
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          _currentIndex == 0 ? 'SPAG' : _currentIndex == 1 ? 'MY REQUESTS' : 'PROFILE',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D2A3F),
            letterSpacing: 1,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildHeaderAction(),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2A8FD4),
          unselectedItemColor: const Color(0xFF6B8FA8),
          selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded, size: 22), 
              activeIcon: Icon(Icons.grid_view_rounded, size: 22),
              label: 'Catalog',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.layers_outlined, size: 22),
              activeIcon: Icon(Icons.layers_rounded, size: 22),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded, size: 22),
              activeIcon: Icon(Icons.person_rounded, size: 22),
              label: 'Profile',
            ),
          ],
        ),
      ),
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