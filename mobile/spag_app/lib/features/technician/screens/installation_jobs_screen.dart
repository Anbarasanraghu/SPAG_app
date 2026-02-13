import 'package:flutter/material.dart';
import '../services/installation_service.dart';
import '../models/installation_job.dart';

class InstallationJobsScreen extends StatefulWidget {
  const InstallationJobsScreen({super.key});

  @override
  State<InstallationJobsScreen> createState() =>
      _InstallationJobsScreenState();
}

class _InstallationJobsScreenState
    extends State<InstallationJobsScreen> {
  late Future<List<InstallationJob>> futureJobs;

  @override
  void initState() {
    super.initState();
    futureJobs = InstallationService.fetchInstallations();
  }

  void refresh() {
    setState(() {
      futureJobs = InstallationService.fetchInstallations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Installation Jobs"),
        elevation: 0,
        backgroundColor: const Color(0xFF0EA5E9),
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: FutureBuilder<List<InstallationJob>>(
        future: futureJobs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading installation jobs...',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        color: Color(0xFFEF4444),
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Error Loading Jobs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final jobs = snapshot.data ?? [];

          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5E9).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.inbox_outlined,
                      color: Color(0xFF0EA5E9),
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Installation Jobs',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'All installations are completed!\nCheck back later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0EA5E9).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.home,
                                color: Color(0xFF0EA5E9),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.customerName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  Text(
                                    job.modelName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF0EA5E9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.phone,
                          'Phone',
                          job.customerPhone,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.location_on,
                          'Address',
                          job.address,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _completeInstallation(job),
                            icon: const Icon(Icons.check_circle),
                            label: const Text(
                              'Complete Installation',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF6B7280),
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _completeInstallation(InstallationJob job) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF10B981),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Complete Installation?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mark installation for ${job.customerName} as complete?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Completing installation...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await InstallationService.completeInstallation(job.requestId);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Installation for ${job.customerName} completed!'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      refresh();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Error: $e'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
