import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/customer/screens/customer_catalog_screen.dart';
import 'features/customer/screens/customer_dashboard_screen.dart';
import 'features/customer/screens/customer_profile_form_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/technician/screens/technician_home_screen.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  Future<(bool, String?)> _checkAuth() async {
    final token = await AuthService.getToken();
    final role = await AuthService.getRole();
    return (token != null, role);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(bool, String?)>(
      future: _checkAuth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final (hasToken, role) = snapshot.data ?? (false, null);

        if (!hasToken) {
          return const LoginScreen();
        }

        // Route based on role
        switch (role) {
          case 'admin':
            return const AdminDashboardScreen();
          case 'technician':
            return const TechnicianHomeScreen();
          case 'customer':
          default:
            return const CustomerDashboardScreen();
        }
      },
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SpagApp());
}

class SpagApp extends StatelessWidget {
  const SpagApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SPAG Service App',
      theme: ThemeData(
        primaryColor: const Color(0xFF0A5ED7), // SPAG blue
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A5ED7),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A5ED7),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const StartupScreen(),
      routes: {
        '/purifier-catalog': (context) => const CustomerCatalogScreen(),
        '/customer-dashboard': (context) => const CustomerDashboardScreen(),
        '/customer-profile': (context) => const CustomerProfileFormScreen(),
      },
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
      },
    );
  }
}
