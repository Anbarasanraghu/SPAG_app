import 'package:flutter/material.dart';
import '../../../core/models/purifier_model.dart';
import '../../../core/api/purifier_service.dart';
import '../../auth/services/auth_service.dart';
import 'customer_home_decider_screen.dart';

class CustomerCatalogScreen extends StatefulWidget {
  const CustomerCatalogScreen({super.key});

  @override
  State<CustomerCatalogScreen> createState() => _CustomerCatalogScreenState();
}

class _CustomerCatalogScreenState extends State<CustomerCatalogScreen> {
  late Future<List<PurifierModel>> _modelsFuture;
  int? _requestingId;

  @override
  void initState() {
    super.initState();

    // 🔍 Debug token existence
    AuthService.getToken().then((token) {
      debugPrint("CUSTOMER CATALOG TOKEN => $token");
    });

    _modelsFuture = PurifierService.listModels().then((models) {
      debugPrint("[CustomerCatalog] Loaded ${models.length} models");
      return models;
    }).catchError((e) {
      debugPrint("[CustomerCatalog] Error loading models: $e");
      throw e;
    });
  }

  Future<void> _request(int id) async {
    setState(() => _requestingId = id);
    try {
      await PurifierService.requestProduct(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Request submitted successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CustomerHomeDeciderScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _requestingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Choose Your Purifier',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue[700]!,
                      Colors.blue[900]!,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<PurifierModel>>(
              future: _modelsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Loading purifiers...',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Failed to load purifiers',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final models = snapshot.data ?? [];

                if (models.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.water_drop_outlined, size: 64, color: Colors.grey[400]),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No purifiers available',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please check back later',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Models',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select the perfect purifier for your needs',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: models.length,
                        itemBuilder: (context, index) {
                          final m = models[index];
                          final isRequesting = _requestingId == m.id;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Card(
                              elevation: 0,
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      Colors.blue[50]!.withOpacity(0.3),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.blue[100]!,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.blue[600]!,
                                                  Colors.blue[800]!,
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blue.withOpacity(0.3),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.water_drop,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  m.name,
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1A1A1A),
                                                    letterSpacing: -0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue[700]!.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    'Model #${m.id}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.blue[700],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.02),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: _InfoChip(
                                                icon: Icons.build_circle_outlined,
                                                label: 'Free Services',
                                                value: '${m.freeServices}',
                                                color: Colors.green[600]!,
                                              ),
                                            ),
                                            Container(
                                              width: 1.5,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.grey[200]!,
                                                    Colors.grey[300]!,
                                                    Colors.grey[200]!,
                                                  ],
                                                ),
                                              ),
                                              margin: const EdgeInsets.symmetric(horizontal: 16),
                                            ),
                                            Expanded(
                                              child: _InfoChip(
                                                icon: Icons.calendar_today,
                                                label: 'Service Interval',
                                                value: '${m.serviceIntervalDays}d',
                                                color: Colors.orange[600]!,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed: isRequesting || _requestingId != null
                                              ? null
                                              : () => _request(m.id),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue[700],
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor: Colors.grey[300],
                                            elevation: 0,
                                            shadowColor: Colors.blue.withOpacity(0.3),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: isRequesting
                                              ? const SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 3,
                                                  ),
                                                )
                                              : const Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.check_circle_outline, size: 22),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Request This Purifier',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        letterSpacing: 0.3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}