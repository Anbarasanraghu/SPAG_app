import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/api/dashboard_service.dart';
import '../../../core/api/service_history_service.dart';
import '../../../core/models/dashboard.dart';
import '../../../core/services/purifier_model_cache.dart';
import '../../../core/services/installation_event_service.dart';
import '../../auth/services/auth_service.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
    
    // 🔹 Listen to installation completion events
    InstallationEventService.installationCompletedNotifier.addListener(_onInstallationCompleted);
  }

  @override
  void dispose() {
    // 🔹 Clean up listener
    InstallationEventService.installationCompletedNotifier.removeListener(_onInstallationCompleted);
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onInstallationCompleted() {
    debugPrint("[CustomerDashboard] Installation event received, refreshing dashboard");
    // The FutureBuilder will automatically rebui on state change if we trigger a rebuild
    setState(() {});
  }

  Future<CustomerDashboard> _loadDashboard() async {
    final token = await AuthService.getToken();
    debugPrint("CUSTOMER DASHBOARD TOKEN => $token");
    
    // Fetch dashboard info
    var dashboard = await DashboardService.fetchDashboard();
    debugPrint("[CustomerDashboard] Dashboard loaded: customerId=${dashboard.customerId}, model=${dashboard.purifierModel}, installDate=${dashboard.installDate}, services=${dashboard.services.length}");
    
    // Try to fetch service history separately
    try {
      debugPrint("[CustomerDashboard] Attempting to fetch service history from separate endpoint...");
      final serviceHistory = await ServiceHistoryService.fetchServiceHistory();
      debugPrint("[CustomerDashboard] Service history fetched: ${serviceHistory.length} records");
      
      // If we got service history from the separate endpoint, use it
      if (serviceHistory.isNotEmpty) {
        debugPrint("[CustomerDashboard] Using service history from separate endpoint");
        dashboard = CustomerDashboard(
          customerId: dashboard.customerId,
          purifierModel: dashboard.purifierModel,
          installDate: dashboard.installDate,
          nextServiceDate: dashboard.nextServiceDate,
          services: serviceHistory,
        );
      }
    } catch (e) {
      debugPrint("[CustomerDashboard] Service history fetch failed: $e");
    }
    
    // Calculate next service date if not provided
    if ((dashboard.nextServiceDate == null || dashboard.nextServiceDate!.isEmpty) && 
        dashboard.installDate.isNotEmpty) {
      try {
        // Get purifier model info to find service interval
        final modelId = int.tryParse(dashboard.purifierModel) ?? 0;
        if (modelId > 0) {
          final model = await PurifierModelCache().getModel(modelId);
          if (model != null) {
            // Parse install date and add service interval
            final installDate = DateTime.parse(dashboard.installDate);
            final nextService = installDate.add(Duration(days: model.serviceIntervalDays));
            final formattedDate = '${nextService.year}-${nextService.month.toString().padLeft(2, '0')}-${nextService.day.toString().padLeft(2, '0')}';
            
            debugPrint("[CustomerDashboard] Calculated next service: $installDate + ${model.serviceIntervalDays}d = $formattedDate");
            
            dashboard = CustomerDashboard(
              customerId: dashboard.customerId,
              purifierModel: dashboard.purifierModel,
              installDate: dashboard.installDate,
              nextServiceDate: formattedDate,
              services: dashboard.services,
            );
          }
        }
      } catch (e) {
        debugPrint("[CustomerDashboard] Error calculating next service date: $e");
      }
    }
    
    debugPrint("[CustomerDashboard] Final nextServiceDate: ${dashboard.nextServiceDate}");
    return dashboard;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'My Purifier',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1A1A1A)),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<CustomerDashboard>(
        future: _loadDashboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1500),
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value * 2 * math.pi,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.water_drop,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      );
                    },
                    onEnd: () {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading your dashboard...',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            debugPrint('CustomerDashboard FutureBuilder error: ${snapshot.error}');
            final errorMsg = snapshot.error.toString();
            if (errorMsg.contains('Installation pending')) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.hourglass_empty,
                        color: Colors.orange.shade400,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Installation Pending',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your installation is pending. Please wait for technician.',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (errorMsg.contains('Installation not found')) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Installation Found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'It looks like you don\'t have a registered installation yet. Please request an installation or contact support.',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red.shade400,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load dashboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Purifier Card
                    _buildPurifierCard(data),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Stats Row
                    _buildQuickStats(data),
                    
                    const SizedBox(height: 24),
                    
                    // Service History Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Service History',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.filter_list, size: 18),
                          label: const Text('Filter'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF6366F1),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    data.services.isEmpty
                        ? _buildEmptyState()
                        : _buildServiceList(data.services),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPurifierCard(CustomerDashboard data) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated background circles
            Positioned(
              top: -30,
              right: -30,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 3),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.water_drop,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Purifier',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FutureBuilder<String>(
                              future: _getModelName(data.purifierModel),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  );
                                }
                                
                                return Text(
                                  snapshot.data ?? data.purifierModel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Installed',
                    data.installDate,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.event_available,
                    'Next Service',
                    data.nextServiceDate ?? 'No upcoming service',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getModelName(String modelIdStr) async {
    try {
      final modelId = int.tryParse(modelIdStr) ?? 0;
      if (modelId == 0) return modelIdStr;
      
      final name = await PurifierModelCache().getModelName(modelId);
      debugPrint('[CustomerDashboard] Model $modelId resolved to: $name');
      return name;
    } catch (e) {
      debugPrint('[CustomerDashboard] Error resolving model name: $e');
      return modelIdStr;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(CustomerDashboard data) {
    final totalServices = data.services.length;
    final completedServices = data.services.where((s) => s.status == 'COMPLETED').length;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Services',
            totalServices.toString(),
            Icons.build_circle_outlined,
            const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completed',
            completedServices.toString(),
            Icons.check_circle_outline,
            const Color(0xFF3B82F6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animValue)),
          child: Opacity(
            opacity: animValue,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceList(List<dynamic> services) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final s = services[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 100)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: s.status == 'COMPLETED'
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  s.status == 'COMPLETED' ? Icons.check_circle : Icons.pending,
                  color: s.status == 'COMPLETED'
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                  size: 24,
                ),
              ),
              title: Text(
                'Service ${s.serviceNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  s.serviceDate,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: s.status == 'COMPLETED'
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  s.status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: s.status == 'COMPLETED'
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history,
                  color: Color(0xFF6366F1),
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No service history yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your service records will appear here',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}