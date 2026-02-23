import 'package:flutter/material.dart';
import '../services/installation_service.dart';
import '../models/installation_job.dart';
import '../../../core/api/purifier_service.dart';
import '../../../core/models/purifier_model.dart';

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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(job.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                job.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(job.status),
                                ),
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

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ASSIGNED':
        return const Color(0xFF3B82F6);
      case 'IN_PROGRESS':
      case 'IN PROGRESS':
        return const Color(0xFFF59E0B);
      case 'COMPLETED':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Future<void> _completeInstallation(InstallationJob job) async {
    // Fetch purifier models first
    List<PurifierModel> models = [];
    try {
      models = await PurifierService.listModels();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load purifier models: $e')),
      );
      return;
    }

    final customerCtrl = TextEditingController(text: job.customerName);
    final addressCtrl = TextEditingController(text: job.address);
    final address2Ctrl = TextEditingController();
    final siteDetailsCtrl = TextEditingController(text: job.address);
    final cityCtrl = TextEditingController();
    final stateCtrl = TextEditingController();
    final pincodeCtrl = TextEditingController();
    final landmarkCtrl = TextEditingController();
    DateTime installationDate = DateTime.now();
    int selectedModelId = job.purifierModelId != 0 ? job.purifierModelId : (models.isNotEmpty ? models[0].id : 0);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Complete Installation'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: customerCtrl,
                    decoration: const InputDecoration(labelText: 'Customer Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: address2Ctrl,
                    decoration: const InputDecoration(labelText: 'Address Line 2'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: cityCtrl,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: stateCtrl,
                    decoration: const InputDecoration(labelText: 'State'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: pincodeCtrl,
                    decoration: const InputDecoration(labelText: 'Pincode'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: landmarkCtrl,
                    decoration: const InputDecoration(labelText: 'Landmark'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: siteDetailsCtrl,
                    decoration: const InputDecoration(labelText: 'Site Details'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: installationDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (d != null) setState(() => installationDate = d);
                          },
                          child: Text('Date: ${installationDate.toIso8601String().split('T')[0]}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedModelId,
                    items: models.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
                    onChanged: (v) => setState(() => selectedModelId = v ?? selectedModelId),
                    decoration: const InputDecoration(labelText: 'Purifier Model'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final payload = {
                    'customer_name': customerCtrl.text.trim(),
                    'address': addressCtrl.text.trim(),
                    'installation_date': installationDate.toIso8601String().split('T')[0],
                    'site_details': siteDetailsCtrl.text.trim(),
                    'purifier_model_id': selectedModelId,
                    'address_line2': address2Ctrl.text.trim(),
                    'city': cityCtrl.text.trim(),
                    'state': stateCtrl.text.trim(),
                    'pincode': pincodeCtrl.text.trim(),
                    'landmark': landmarkCtrl.text.trim(),
                  };

                  // Basic validation (cast to String to avoid dynamic type issues)
                  if ((payload['customer_name'] ?? '').toString().isEmpty || (payload['address'] ?? '').toString().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill required fields')));
                    return;
                  }

                  Navigator.pop(context, payload);
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );

    if (result == null) return;

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
      await InstallationService.completeInstallation(job, result);

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
