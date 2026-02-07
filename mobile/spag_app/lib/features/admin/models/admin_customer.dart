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
      customerId: json['customer_id'],
      name: json['name'] ?? 'Unknown',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      installations: json['installations'] ?? 0,
    );
  }
}
