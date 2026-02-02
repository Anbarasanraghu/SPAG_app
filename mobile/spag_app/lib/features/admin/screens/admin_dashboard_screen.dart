import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _adminTile(
            context,
            title: "Manage Users & Roles",
            onTap: () {
              // open role management screen
            },
          ),
          _adminTile(
            context,
            title: "Technician Service Logs",
            onTap: () {
              // open technician logs
            },
          ),
          _adminTile(
            context,
            title: "Pending Services",
            onTap: () {
              // open pending services
            },
          ),
          _adminTile(
            context,
            title: "Assign Technician",
            onTap: () {
              // open assign screen
            },
          ),
          _adminTile(
            context,
            title: "All Customers",
            onTap: () {
              // open customer management
            },
          ),
        ],
      ),
    );
  }

  Widget _adminTile(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
