import 'package:flutter/material.dart';
import '../../core/api/dashboard_service.dart';
import 'customer_dashboard_screen.dart';
import 'customer_catalog_screen.dart';

class CustomerHomeDeciderScreen extends StatefulWidget {
  const CustomerHomeDeciderScreen({super.key});

  @override
  State<CustomerHomeDeciderScreen> createState() =>
      _CustomerHomeDeciderScreenState();
}

class _CustomerHomeDeciderScreenState
    extends State<CustomerHomeDeciderScreen> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    try {
      final dashboard = await DashboardService.fetchDashboard();

      if (!mounted) return;

      // Decide by installation presence (purifierModel/installDate/customerId)
      if ((dashboard.purifierModel.isEmpty && dashboard.installDate.isEmpty) || dashboard.customerId == 0) {
        // NEW USER → Catalog
        debugPrint('CustomerHomeDecider: No installation found, navigating to Catalog');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CustomerCatalogScreen(),
          ),
        );
      } else {
        // OLD / ACTIVE USER → Dashboard
        debugPrint('CustomerHomeDecider: Installation found, navigating to Dashboard');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CustomerDashboardScreen(),
          ),
        );
      }
    } catch (e, st) {
      // Print out full error & stack to help locate cause
      debugPrint('Dashboard fetch error: $e');
      debugPrint('$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading customer data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
