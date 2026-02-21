import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import '../../customer/services/customer_profile_service.dart';
import '../screens/customer_dashboard_screen.dart';
import '../../auth/controller/auth_controller.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../technician/screens/technician_home_screen.dart';
import '../../auth/screens/login_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _loading = true;
  String? _token;
  final _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final token = await AuthService.getToken();
    final role = await AuthService.getRole();
    
    // Don't check profile for admin/technician users
    if (role == 'admin' || role == 'Admin' || role == 'technician' || role == 'Technician') {
      setState(() {
        _token = token;
        _loading = false;
      });
      return;
    }
    
    setState(() {
      _token = token;
      _loading = false;
    });
  }

  Future<void> _goToDashboardIfReady() async {
    if (_token == null) return;
    
    final role = await AuthService.getRole();
    // Admin/technician users go directly to their dashboards
    if (role == 'admin' || role == 'Admin') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
      return;
    } else if (role == 'technician' || role == 'Technician') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TechnicianHomeScreen()));
      return;
    }
    
    // For customers, check profile
    final exists = await CustomerProfileService.profileExists();
    if (!mounted) return;
    if (!exists) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Installation Pending'),
          content: const Text('Your installation is pending. Please wait for technician.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()));
    }
  }

  Future<void> _showLogin() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    if (result is AuthResponse) {
      await AuthService.saveToken(result.token);
      await AuthService.saveRole(result.role);
      setState(() => _token = result.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_token == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(onPressed: _showLogin, child: const Text('Login')),
            const SizedBox(height: 12),
            const Text('Or request a product from the Catalog to register'),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(onPressed: _goToDashboardIfReady, child: const Text('Open Dashboard')),
          const SizedBox(height: 12),
          ElevatedButton(
              onPressed: () async {
                await AuthService.logout();
                setState(() => _token = null);
              },
              child: const Text('Logout')),
        ],
      ),
    );
  }
}
