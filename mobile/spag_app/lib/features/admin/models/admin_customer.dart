class AdminCustomer {
  final int customerId;
  final String name;
  final String phone;
  final String address;
  final int installations;

  AdminCustomer({
    required this.customerId,
    required this.name,
    required this.phone,
    required this.address,
    required this.installations,
  });

  factory AdminCustomer.fromJson(Map<String, dynamic> json) {
    return AdminCustomer(
      customerId: (json['customer_id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? 'Unknown',
      phone: (json['phone'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      installations: (json['installations'] as int?) ?? 0,
    );
  }
}
