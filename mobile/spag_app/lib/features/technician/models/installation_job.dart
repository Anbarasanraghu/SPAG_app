class InstallationJob {
  final int requestId;
  final String customerName;
  final String customerPhone;
  final String address;
  final String modelName;
  final String status;

  InstallationJob({
    required this.requestId,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.modelName,
    required this.status,
  });

  factory InstallationJob.fromJson(Map<String, dynamic> json) {
    return InstallationJob(
      requestId: json['request_id'] as int? ?? 0,
      customerName: json['customer_name'] as String? ?? 'Unknown',
      customerPhone: json['customer_phone'] as String? ?? 'N/A',
      address: json['address'] as String? ?? 'N/A',
      modelName: json['model_name'] as String? ?? 'Unknown',
      status: json['status'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'address': address,
      'model_name': modelName,
      'status': status,
    };
  }
}
