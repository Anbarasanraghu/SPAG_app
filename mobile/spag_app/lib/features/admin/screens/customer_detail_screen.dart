import 'package:flutter/material.dart';
import '../services/admin_customer_service.dart';
import '../models/admin_customer.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  bool loading = true;
  AdminCustomer? customer;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    try {
      final data = await AdminCustomerService.fetchCustomer(widget.customerId);
      if (!mounted) return;
      setState(() {
        customer = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load customer: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  String _getInitials(String name) {
    List<String> names = name.trim().split(' ');
    if (names.length == 1) {
      return names[0].substring(0, 1).toUpperCase();
    }
    return (names[0].substring(0, 1) + names[names.length - 1].substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Customer Details'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : customer == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No customer data',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Card with Avatar
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue[600]!,
                              Colors.blue[800]!,
                            ],
                          ),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                            child: Column(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getInitials(customer!.name),
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  customer!.name,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'ID: ${customer!.customerId}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Content Cards
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Contact Information Card
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(Icons.contact_phone,
                                                color: Colors.blue[700], size: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Contact Information',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      _row('Phone', customer!.phone),
                                      const SizedBox(height: 8),
                                      _row('Address', customer!.address),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}