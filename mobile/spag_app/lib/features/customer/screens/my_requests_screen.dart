import 'package:flutter/material.dart';
import '../../../core/api/purifier_service.dart';

// ─── COLOUR TOKENS ───────────────────────────────────────
// bg: #F5F9FF  panels: #FFFFFF  surface: #EAF3FF
// accent: #2A8FD4  mid: #5AABDE  soft: #C4DFF5
// text: #0D2A3F  muted: #6B8FA8  hairline: #D6E8F5

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
      backgroundColor: _bg,
      appBar: AppBar(
        surfaceTintColor: _bg,
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'MY REQUESTS',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: _muted,
                letterSpacing: 2.2,
                fontFamily: 'monospace',
              ),
            ),
            SizedBox(height: 1),
            Text(
              'Track your orders',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _text,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _hairline),
        ),
        actions: [
          GestureDetector(
            onTap: _reload,
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _soft),
              ),
              child: const Row(
                children: [
                  Icon(Icons.refresh_rounded, size: 13, color: _accent),
                  SizedBox(width: 4),
                  Text(
                    'REFRESH',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                      letterSpacing: 1.4,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          // ── LOADING ──
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _panel,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withOpacity(0.10),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(_accent),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Loading requests...',
                    style: TextStyle(
                      fontSize: 11,
                      color: _muted,
                      fontFamily: 'monospace',
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            );
          }

          // ── ERROR / EMPTY ──
          if (snapshot.hasError || (snapshot.data ?? []).isEmpty) {
            return _buildEmptyState(
              snapshot.hasError ? 'Error loading requests' : 'No requests yet',
            );
          }

          final requests = snapshot.data!;

          // ── LIST ──
          return RefreshIndicator(
            color: _accent,
            backgroundColor: _panel,
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final req = requests[index] as Map<String, dynamic>;
                return _buildRequestItem(req);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestItem(Map<String, dynamic> req) {
    final statusTheme  = _getStatusTheme(req['status']);
    final Color color  = statusTheme['color'];
    final String label = (req['status'] ?? 'Pending')
        .toUpperCase()
        .replaceAll('_', ' ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _hairline),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Status icon ──
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusTheme['icon'], color: color, size: 18),
          ),
          const SizedBox(width: 11),

          // ── Content ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req['product_name'] ?? 'Purifier Request',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _text,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'ID: #${req['id']}  ·  ${req['created_at']}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: _muted,
                    fontFamily: 'monospace',
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Status pill ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 1.0,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.inbox_outlined, size: 36, color: _soft),
          ),
          const SizedBox(height: 14),
          Text(
            msg,
            style: const TextStyle(
              fontSize: 12,
              color: _muted,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}