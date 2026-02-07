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
      id: json['id'],
      customerId: json['customer_id'],
      purifierModelId: json['purifier_model_id'],
      status: json['status'],
    );
  }
}
