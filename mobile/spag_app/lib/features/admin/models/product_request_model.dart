class ProductRequest {
  final int id;
  final int? customerId;
  final int? userId;
  final int purifierModelId;
  final String status;
  final String phone;
  final String customerName;
  final String? address;
  final String? city;
  final DateTime createdAt;

  ProductRequest({
    required this.id,
    this.customerId,
    this.userId,
    required this.purifierModelId,
    required this.status,
    required this.phone,
    required this.customerName,
    this.address,
    this.city,
    required this.createdAt,
  });

  factory ProductRequest.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final name = customer?['name'] as String? ?? 'Unknown';
    final phone = customer?['phone'] as String? ?? 'N/A';
    final address = customer?['address_line1'] as String?;
    final city = customer?['city'] as String?;
    final createdAt = json['created_at'] != null 
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now();

    return ProductRequest(
      id: (json['id'] as int?) ?? 0,
      customerId: json['customer_id'] as int?,
      userId: json['user_id'] as int?,
      purifierModelId: (json['purifier_model_id'] as int?) ?? 0,
      status: (json['status'] as String?) ?? '',
      phone: phone,
      customerName: name,
      address: address,
      city: city,
      createdAt: createdAt,
    );
  }
}

