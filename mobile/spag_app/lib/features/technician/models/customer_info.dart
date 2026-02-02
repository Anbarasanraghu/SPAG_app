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
      customerId: json['customer_id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
    );
  }
}
