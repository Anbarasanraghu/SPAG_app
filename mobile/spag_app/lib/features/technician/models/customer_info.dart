class CustomerInfo {
  final int customerId;
  final String name;
  final String phone;
  final String address;

  CustomerInfo({
    required this.customerId,
    required this.name,
    required this.phone,
    required this.address,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      customerId: json['customer_id'] ?? 0,
      name: (json['name'] as String?) ?? 'Unknown',
      phone: (json['phone'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
    );
  }
}

