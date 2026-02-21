class TechnicianService {
  final int serviceId;
  final int customerId;
  final int installationId;
  final int serviceNumber;
  final String serviceDate;
  final String? status;

  TechnicianService({
    required this.serviceId,
    required this.customerId,
    required this.installationId,
    required this.serviceNumber,
    required this.serviceDate,
    this.status,
  });

  factory TechnicianService.fromJson(Map<String, dynamic> json) {
    return TechnicianService(
      serviceId: (json['id'] ?? json['service_id'] as int?) ?? 0,
      customerId: (json['customer_id'] as int?) ?? 0,
      installationId: (json['installation_id'] as int?) ?? 0,
      serviceNumber: (json['service_number'] as int?) ?? 0,
      serviceDate: (json['service_date'] as String?) ?? '',
      status: json['status'],
    );
  }
}
