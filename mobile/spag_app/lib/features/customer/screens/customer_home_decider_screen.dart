import 'package:flutter/material.dart';

import '../../../core/api/dashboard_service.dart';
import '../../customer/services/customer_profile_service.dart';
import 'customer_dashboard_screen.dart';
import 'customer_catalog_screen.dart';
import 'customer_profile_form_screen.dart';

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
      /// 🔹 STEP 1: Try to fetch dashboard (best indicator of existing customer)
      debugPrint('CustomerHomeDecider: Attempting to fetch dashboard...');
      
      try {
        final dashboard = await DashboardService.fetchDashboard();

        if (!mounted) return;

        debugPrint('CustomerHomeDecider: Dashboard fetched successfully');
        debugPrint(
            'CustomerHomeDecider: customerId=${dashboard.customerId}, purifierModel=${dashboard.purifierModel}, installDate=${dashboard.installDate}');

        /// 🔹 STEP 2: Decide by installation
        if ((dashboard.purifierModel.isEmpty &&
                dashboard.installDate.isEmpty) ||
            dashboard.customerId == 0) {
          // EXISTING CUSTOMER but NO INSTALLATION → CATALOG
          debugPrint(
              'CustomerHomeDecider: Existing customer, no installation → Catalog');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const CustomerCatalogScreen(),
            ),
          );
        } else {
          // EXISTING CUSTOMER WITH INSTALLATION → DASHBOARD
          debugPrint(
              'CustomerHomeDecider: Existing customer with installation → Dashboard');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const CustomerDashboardScreen(),
            ),
          );
        }
        return;
      } catch (dashboardErr) {
        debugPrint(
            'CustomerHomeDecider: Dashboard fetch failed: $dashboardErr, checking alternative...');
      }

      if (!mounted) return;

      /// 🔹 FALLBACK: Check if customer profile exists 
      debugPrint('CustomerHomeDecider: Checking if profile exists...');
      final profileExists =
          await CustomerProfileService.profileExists();

      if (!mounted) return;

      /// ❌ NO PROFILE → FORCE DETAILS SCREEN
      if (!profileExists) {
        debugPrint(
            'CustomerHomeDecider: No customer profile, navigating to Profile Form');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CustomerProfileFormScreen(),
          ),
        );
        return;
      }

      /// ✅ PROFILE EXISTS but dashboard fetch failed → CATALOG
      debugPrint(
          'CustomerHomeDecider: Profile exists but dashboard unavailable → Catalog');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CustomerCatalogScreen(),
        ),
      );
    } catch (e, st) {
      debugPrint('CustomerHomeDecider error: $e');
      debugPrint('$st');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading customer data: $e'),
        ),
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
