class ProductRequest {
  final int id;
  final int customerId;
  final int purifierModelId;
  final String status;

  ProductRequest({
    required this.id,
    required this.customerId,
    required this.purifierModelId,
    required this.status,
  });

  factory ProductRequest.fromJson(Map<String, dynamic> json) {
    return ProductRequest(
      id: (json['id'] as int?) ?? 0,
      customerId: (json['customer_id'] as int?) ?? 0,
      purifierModelId: (json['purifier_model_id'] as int?) ?? 0,
      status: (json['status'] as String?) ?? '',
    );
  }
}

