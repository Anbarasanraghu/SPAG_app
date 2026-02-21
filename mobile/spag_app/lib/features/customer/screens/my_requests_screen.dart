import 'package:flutter/material.dart';
import '../../../core/api/purifier_service.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  late Future<List<dynamic>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = PurifierService.listUserRequests();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _requestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return const Center(child: Text('No requests found'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final r = requests[index] as Map<String, dynamic>;
            return ListTile(
              title: Text(r['product_name'] ?? 'Request #${r['id'] ?? index}'),
              subtitle: Text(r['status'] ?? 'Pending'),
              trailing: Text(r['created_at'] ?? ''),
            );
          },
        );
      },
    );
  }
}
