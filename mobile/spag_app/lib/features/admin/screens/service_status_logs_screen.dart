import 'package:flutter/material.dart';
import '../services/service_logs_service.dart';
import 'service_detail_screen.dart';

class ServiceStatusLogsScreen extends StatefulWidget {
  final int? serviceId;
  const ServiceStatusLogsScreen({super.key, this.serviceId});

  @override
  State<ServiceStatusLogsScreen> createState() => _SerKaNCgLvMEXxNzMxj2F7FYi1AdRrTo6Nhu();
}

class _SerKaNCgLvMEXxNzMxj2F7FYi1AdRrTo6Nhu extends State<ServiceStatusLogsScreen> {
  bool loading = true;
  List<dynamic> logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final data = widget.serviceId == null
          ? await ServiceLogsService.getAllServiceStatusLogs()
          : await ServiceLogsService.getServiceStatusLogs(widget.serviceId!);
      setState(() {
        logs = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading status logs: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('complete') || statusLower.contains('done') || statusLower.contains('success')) {
      return Colors.green[600]!;
    } else if (statusLower.contains('progress') || statusLower.contains('active') || statusLower.contains('ongoing')) {
      return Colors.blue[600]!;
    } else if (statusLower.contains('pending') || statusLower.contains('waiting') || statusLower.contains('scheduled')) {
      return Colors.orange[600]!;
    } else if (statusLower.contains('cancel') || statusLower.contains('reject') || statusLower.contains('failed')) {
      return Colors.red[600]!;
    }
    return Colors.grey[700]!;
  }

  String _formatDateTime(String dateTime) {
    if (dateTime.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
      }
    } catch (e) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Service Status Logs'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1F36),
        elevation: 0,
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No status logs found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status changes will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final serviceId = log['service_id'] ?? log['serviceId'] ?? log['id'];
                    final oldStatus = log['old_status'] ?? '-';
                    final newStatus = log['new_status'] ?? '-';
                    final changedAt = log['changed_at']?.toString() ?? '';
                    final changedBy = log['changed_by'] ?? '-';
                    final changedByRole = log['changed_by_role'] ?? '-';
                    
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
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
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey[100]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Status Change',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[500],
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.grey[300]!,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  oldStatus,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey[700],
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Icon(
                                                Icons.arrow_forward,
                                                size: 18,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                            Flexible(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(newStatus).withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: _getStatusColor(newStatus).withValues(alpha: 0.3),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: Text(
                                                  newStatus,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: _getStatusColor(newStatus),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (serviceId != null)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey[200]!,
                                      Colors.grey[100]!,
                                      Colors.grey[200]!,
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.purple[50],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.person_outline,
                                      size: 18,
                                      color: Colors.purple[700],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Changed by: $changedBy',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1A1F36),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '($changedByRole)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (changedAt.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatDateTime(changedAt),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
