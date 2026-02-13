import 'package:flutter/material.dart';
import '../models/admin_customer.dart';
import '../services/admin_customer_service.dart';
import 'customer_detail_screen.dart';

class AllCustomersScreen extends StatefulWidget {
  const AllCustomersScreen({super.key});

  @override
  State<AllCustomersScreen> createState() => _AllCustomersScreenState();
}

class _AllCustomersScreenState extends State<AllCustomersScreen> {
  bool loading = true;
  List<AdminCustomer> customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final data = await AdminCustomerService.fetchCustomers();
      setState(() {
        customers = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text("Failed to load customers"),
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

  Color _getAvatarColor(int index) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
    ];
    return colors[index % colors.length];
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "All Customers",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1F36),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Loading customers...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : customers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.people_outline,
                          size: 56,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "No customers found",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1F36),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Customer list is empty",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Stats Header
                    Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.groups,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Customers",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${customers.length}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Customers List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final c = customers[index];
                          final avatarColor = _getAvatarColor(index);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
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
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CustomerDetailScreen(
                                        customerId: c.customerId,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      // Avatar with initials
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              avatarColor,
                                              avatarColor.withOpacity(0.8),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _getInitials(c.name),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Customer Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              c.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(0xFF1A1F36),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            
                                            // Phone
                                            Row(
                                              children: [
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF10B981)
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                  ),
                                                  child: const Icon(
                                                    Icons.phone,
                                                    size: 12,
                                                    color: Color(0xFF10B981),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    c.phone,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            
                                            // Address
                                            Row(
                                              children: [
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF3B82F6)
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                  ),
                                                  child: const Icon(
                                                    Icons.location_on,
                                                    size: 12,
                                                    color: Color(0xFF3B82F6),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    c.address,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey[600],
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Arrow Icon
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: avatarColor.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          color: avatarColor,
                                          size: 14,
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
                    ),
                  ],
                ),
    );
  }
}