import 'package:flutter/material.dart';
import '../../../core/api/purifier_service.dart';
import '../../../core/ui/ui_kit.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  late Future<List<dynamic>> _requestsFuture;

  static const Color _bg       = Color(0xFFF5F9FF);
  static const Color _panel    = Color(0xFFFFFFFF);
  static const Color _surface  = Color(0xFFEAF3FF);
  static const Color _accent   = Color(0xFF2A8FD4);
  static const Color _soft     = Color(0xFFC4DFF5);
  static const Color _text     = Color(0xFF0D2A3F);
  static const Color _muted    = Color(0xFF6B8FA8);
  static const Color _hairline = Color(0xFFD6E8F5);

  @override
  void initState() {
    super.initState();
    _requestsFuture = PurifierService.listUserRequests();
  }

  void _reload() {
    setState(() {
      _requestsFuture = PurifierService.listUserRequests();
    });
  }

  Map<String, dynamic> _getStatusTheme(String? status) {
    final s = (status ?? 'PENDING').toUpperCase().replaceAll(' ', '_');
    switch (s) {
      case 'PENDING':
        return {'color': const Color(0xFFD4842A), 'icon': Icons.access_time_rounded};
      case 'ASSIGNED':
        return {'color': _accent, 'icon': Icons.person_search_rounded};
      case 'INSTALLATION_COMPLETED':
      case 'COMPLETED':
        return {'color': const Color(0xFF2A9D6B), 'icon': Icons.check_circle_rounded};
      case 'CANCELLED':
        return {'color': const Color(0xFFE05A5A), 'icon': Icons.cancel_rounded};
      default:
        return {'color': _muted, 'icon': Icons.help_outline_rounded};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      bottomNavigationBar: const SpagFooterLogo(),
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        title: const Text(
          'My Requests',
          style: TextStyle(
            color: kInk,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: kInk),
      ),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _requestsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: kBlush, size: 48),
                      const SizedBox(height: 16),
                      const Text('Failed to load requests', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(snapshot.error.toString(), style: const TextStyle(color: kBlush)),
                      const SizedBox(height: 20),
                      PillButton(
                        label: 'Retry',
                        loading: false,
                        onTap: () => setState(() {
                          _requestsFuture = PurifierService.listUserRequests();
                        }),
                      ),
                    ],
                  ),
                ),
              );
            }

            final requests = snapshot.data ?? [];

            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_rounded, color: kLavender, size: 60),
                    const SizedBox(height: 16),
                    const Text('No requests found', style: TextStyle(fontWeight: FontWeight.w600, color: kInk2)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final r = requests[index] as Map<String, dynamic>;
                return BentoCard(
                  color: kLavender,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: kLavender.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.assignment_turned_in_rounded, color: kLavender, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r['product_name'] ?? 'Request #${r['id'] ?? index}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: kInk,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                MiniChip(
                                  emoji: '⏳',
                                  label: r['status'] ?? 'Pending',
                                  color: kMint,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  r['created_at'] ?? '',
                                  style: const TextStyle(fontSize: 12, color: kInk2),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}