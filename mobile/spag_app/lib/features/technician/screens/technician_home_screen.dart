import 'package:flutter/material.dart';
import '../models/technician_service.dart';
import '../services/technician_api.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({super.key});

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  late Future<List<TechnicianService>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = TechnicianApi.getUpcomingServices();
  }

  void _refresh() {
    setState(() {
      _servicesFuture = TechnicianApi.getUpcomingServices();
    });
  }

  Future<void> _complete(TechnicianService s) async {
    await TechnicianApi.completeService(
      serviceId: s.serviceId,
      customerId: s.customerId,
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Technician Services')),
      body: FutureBuilder<List<TechnicianService>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No upcoming services'));
          }

          final services = snapshot.data!;

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final s = services[index];

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  onTap: () async {
                    final customer =
                        await TechnicianApi.getCustomerInfo(s.customerId);

                    showModalBottomSheet(
                      context: context,
                      builder: (_) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customer.name,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('📞 ${customer.phone}'),
                            const SizedBox(height: 8),
                            Text('📍 ${customer.address}'),
                          ],
                        ),
                      ),
                    );
                  },
                  title: Text('Service ${s.serviceNumber}'),
                  subtitle:
                      Text('Customer ID: ${s.customerId}\n${s.serviceDate}'),
                  trailing: ElevatedButton(
                    onPressed: () => _complete(s),
                    child: const Text('Complete'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
