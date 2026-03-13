import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/customer/screens/customer_catalog_screen.dart';
import 'features/customer/screens/customer_main_screen.dart';
import 'features/customer/screens/customer_dashboard_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/technician/screens/technician_home_screen.dart';

class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});

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

        // Always start with catalog, but route authenticated users to their dashboards
        if (hasToken && role != null) {
          debugPrint('[AuthCheckScreen] User authenticated with role: $role');
          switch (role) {
            case 'admin':
            case 'Admin':
              debugPrint('[AuthCheckScreen] Routing admin to AdminDashboardScreen');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                );
              });
              break;
            case 'technician':
            case 'Technician':
              debugPrint('[AuthCheckScreen] Routing technician to TechnicianHomeScreen');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const TechnicianHomeScreen()),
                );
              });
              break;
            case 'customer':
            case 'Customer':
            default:
              debugPrint('[AuthCheckScreen] Customer staying on catalog');
              break;
          }
        } else {
          debugPrint('[AuthCheckScreen] No authentication, showing catalog');
        }

        // Default to catalog for everyone
        return CustomerMainScreen();
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
      home: const AuthCheckScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/purifier-catalog': (context) => const CustomerCatalogScreen(),
        '/customer-dashboard': (context) => const CustomerDashboardScreen(),
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
