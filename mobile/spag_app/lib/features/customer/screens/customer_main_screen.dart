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
    debugPrint('[CustomerMainScreen] _loadRole: loaded role = $role');
    setState(() {});
  }

  static const List<Widget> _pages = <Widget>[
    CustomerCatalogScreen(),
    MyRequestsScreen(),
    ProfileTab(),
  ];

  static const List<String> _titles = <String>['Catalog', 'My Requests', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          if (role == null) ...[
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: const Text(
                'Login',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.dashboard),
              onPressed: _goToDashboard,
            ),
          ],
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Catalog'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'My Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void _goToDashboard() {
    debugPrint('DEBUG: Going to dashboard with role: $role');
    Widget dashboard;
    switch (role) {
      case 'admin':
      case 'Admin':
        dashboard = const AdminDashboardScreen();
        break;
      case 'technician':
      case 'Technician':
        dashboard = const TechnicianHomeScreen();
        break;
      case 'customer':
      case 'Customer':
      default:
        dashboard = const CustomerDashboardScreen();
        break;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => dashboard),
    );
  }
}
