import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/ui/ui_kit.dart';
import 'customer_catalog_screen.dart';
import 'my_requests_screen.dart';
import 'profile_tab.dart';

// ─── PALETTE (matches CustomerMainScreen) ────────────────────────────────────
const _bgColor = Color(0xFFF5F4F0);
const _ink = Color(0xFF111110);
const _ink2 = Color(0xFF8A8880);
const _darkPill = Color(0xFF1A1A18);
const _lavender = Color(0xFFD5CCFF);
const _mint = Color(0xFFBDF0D8);
const _sky = Color(0xFFBFE0F5);
const _peach = Color(0xFFF8DBBF);

class ProductSelectionScreen extends StatefulWidget {
  const ProductSelectionScreen({super.key});

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 0) return;
          if (i == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MyRequestsScreen()),
            );
          }
          if (i == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfileTab()),
            );
          }
        },
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _Header()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _ProductCard(
                      title: 'Water Level Indicator',
                      subtitle: 'Monitor water level automatically',
                      icon: Icons.water_drop,
                      accent: _sky,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WaterLevelIndicatorScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _ProductCard(
                      title: 'Water Purifier',
                      subtitle: 'Choose a purifier model and request it',
                      icon: Icons.cleaning_services,
                      accent: _mint,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CustomerCatalogScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tip: Your requests will show up in "My Requests" after you submit them.',
                      style: TextStyle(fontSize: 12, color: _ink2),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: _darkPill,
          borderRadius: BorderRadius.circular(28),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _sky.withValues(alpha: 0.18),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              right: 60,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _mint.withValues(alpha: 0.15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose a Product',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Select a product to continue',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const Spacer(),
                  Row(
                    children: const [
                      _HeaderPill(label: 'Auto updates', color: _sky),
                      SizedBox(width: 8),
                      _HeaderPill(label: 'Easy requests', color: _mint),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final String label;
  final Color color;

  const _HeaderPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _ProductCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _darkPill,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: _ink2),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _ink2),
          ],
        ),
      ),
    );
  }
}

class WaterLevelIndicatorScreen extends StatefulWidget {
  const WaterLevelIndicatorScreen({super.key});

  @override
  State<WaterLevelIndicatorScreen> createState() => _WaterLevelIndicatorScreenState();
}

class _WaterLevelIndicatorScreenState extends State<WaterLevelIndicatorScreen> {
  double _level = 0.65;
  bool _auto = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_auto) return;
      setState(() {
        _level = (0.4 + (0.6 * (DateTime.now().second / 60))).clamp(0.0, 1.0);
      });
    });
  }

  void _toggleAuto() {
    setState(() {
      _auto = !_auto;
      if (_auto) {
        _startAutoRefresh();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _refreshOnce() {
    setState(() => _level = (0.3 + (0.7 * (DateTime.now().millisecond / 1000))).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: _ink),
        title: const Text('Water Level Indicator', style: TextStyle(color: _ink)),
      ),
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current water level',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _ink2),
                    ),
                    const SizedBox(height: 16),
                    Stack(
                      children: [
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: _ink2.withValues(alpha: 0.3), width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              heightFactor: _level,
                              child: Container(
                                color: _sky,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Text(
                              '${(_level * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 46,
                                fontWeight: FontWeight.w900,
                                color: _ink,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _auto
                          ? 'Auto-refresh is on (updates every few seconds)'
                          : 'Auto-refresh is off. Tap the button to update.',
                      style: const TextStyle(fontSize: 13, color: _ink2),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _toggleAuto,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _auto ? _darkPill : _mint,
                            ),
                            child: Text(_auto ? 'Stop Auto' : 'Start Auto'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _refreshOnce,
                            child: const Text('Refresh Now'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pro Tip: Connect the indicator to your home sensor hardware to get real-time readings. This screen simulates the behavior for demo purposes.',
                style: TextStyle(fontSize: 12, color: _ink2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Color color;
  const _NavItem({required this.icon, required this.label, required this.color});
}

const _navItems = [
  _NavItem(icon: Icons.home_rounded, label: 'Products', color: _lavender),
  _NavItem(icon: Icons.list_alt_rounded, label: 'Requests', color: _mint),
  _NavItem(icon: Icons.person_rounded, label: 'Profile', color: _peach),
];

// ─────────────────────────────────────────────────────────────────────────────
// FLOATING PILL NAVBAR
// ─────────────────────────────────────────────────────────────────────────────
class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: _darkPill,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final item = items[i];
            final isSelected = i == currentIndex;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? item.color.withValues(alpha: 0.22)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      color: isSelected ? item.color : _ink2,
                      size: 22,
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: item.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

