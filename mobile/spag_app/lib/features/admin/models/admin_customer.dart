class AdminCustomer {
  final int customerId;
  final String name;
  final String phone;
  final String address;
  final int installations;
  final String? technicianName;
  final int? technicianId;

  AdminCustomer({
    required this.customerId,
    required this.name,
    required this.phone,
    required this.address,
    required this.installations,
    this.technicianName,
    this.technicianId,
  });

  factory AdminCustomer.fromJson(Map<String, dynamic> json) {
    // Extract technician info from nested structure
    final technician = json['technician'] as Map<String, dynamic>?;
    final technicianFirstName = technician?['first_name'] as String? ?? '';
    final technicianLastName = technician?['last_name'] as String? ?? '';
    final technicianFullName = '$technicianFirstName $technicianLastName'.trim();
    
    return AdminCustomer(
      customerId: (json['customer_id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? 'Unknown',
      phone: (json['phone'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      installations: (json['installations'] as int?) ?? 0,
      technicianName: technicianFullName.isEmpty ? null : technicianFullName,
      technicianId: technician?['id'] as int?,
    );
  }
}

