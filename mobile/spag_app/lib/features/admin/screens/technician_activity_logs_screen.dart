import 'package:flutter/material.dart';
import '../services/service_logs_service.dart';
import 'service_detail_screen.dart';

class TechnicianActivityLogsScreen extends StatefulWidget {
  final int? technicianId;
  const TechnicianActivityLogsScreen({super.key, this.technicianId});

  @override
  State<TechnicianActivityLogsScreen> createState() => _TechnicianActivityLogsScreenState();
}

class _TechnicianActivityLogsScreenState extends State<TechnicianActivityLogsScreen> {
  bool loading = true;
  List<dynamic> logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final data = widget.technicianId == null
          ? await ServiceLogsService.getAllTechnicianActivityLogs()
          : await ServiceLogsService.getTechnicianActivityLogs(widget.technicianId!);
      setState(() {
        logs = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading activity logs: $e')),
        );
      }
    }
  }

  Color _actionColor(String action) {
    switch (action) {
      case 'COMPLETED':
        return const Color(0xFF10B981);
      case 'ASSIGNED':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Technician Activity Logs'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1F36),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
              ? Center(child: Text('No activity logs found'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final serviceId = log['service_id'] ?? log['serviceId'] ?? log['id'];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: serviceId != null
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ServiceDetailScreen(serviceId: serviceId),
                                  ),
                                );
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _actionColor(log['action'] ?? '' ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.run_circle,
                                  color: _actionColor(log['action'] ?? ''),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log['action']?.toString() ?? '-',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Service: ${log['service_id'] ?? '-'}'),
                                    const SizedBox(height: 6),
                                    Text('When: ${log['logged_at'] ?? log['created_at'] ?? '-'}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
