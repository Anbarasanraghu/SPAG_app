class InstallationJob {
  final int requestId;
  final int? serviceId;
  final String customerName;
  final String customerPhone;
  final String address;
  final String modelName;
  final int purifierModelId;
  final String status;

  InstallationJob({
    required this.requestId,
    this.serviceId,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.modelName,
    required this.purifierModelId,
    required this.status,
  });

  factory InstallationJob.fromJson(Map<String, dynamic> json) {
    return InstallationJob(
      requestId: json['request_id'] as int? ?? 0,
      customerName: json['customer_name'] as String? ?? '',
      customerPhone: json['customer_phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      modelName: json['model_name'] as String? ?? 'Unknown',
      purifierModelId: json['purifier_model_id'] as int? ?? 0,
      status: json['status'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'service_id': serviceId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'address': address,
      'model_name': modelName,
      'purifier_model_id': purifierModelId,
      'status': status,
    };
  }
}
