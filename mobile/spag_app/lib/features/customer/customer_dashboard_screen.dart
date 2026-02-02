import 'package:flutter/material.dart';
import '../../core/api/dashboard_service.dart';
import '../../core/models/dashboard.dart';

class CustomerDashboardScreen extends StatelessWidget {
  const CustomerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Purifier')),
      body: FutureBuilder<CustomerDashboard>(
        future: DashboardService.fetchDashboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load dashboard'));
          }

          final data = snapshot.data!;

          return Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.purifierModel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text('Installed on: ${data.installDate}'),
              const SizedBox(height: 6),
              Text(
                'Next Service: ${data.nextServiceDate ?? "No upcoming service"}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Service History',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: ListView.builder(
          itemCount: data.services.length,
          itemBuilder: (context, index) {
            final s = data.services[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text('Service ${s.serviceNumber}'),
                subtitle: Text(s.serviceDate),
                trailing: Text(
                  s.status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: s.status == 'COMPLETED'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  ),
);
        },
      ),
    );
  }
}
