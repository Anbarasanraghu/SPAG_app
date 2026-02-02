class TechnicianService {
  final int serviceId;
  final int customerId;
  final int installationId;
  final int serviceNumber;
  final String serviceDate;

  TechnicianService({
    required this.serviceId,
    required this.customerId,
    required this.installationId,
    required this.serviceNumber,
    required this.serviceDate,
  });

  factory TechnicianService.fromJson(Map<String, dynamic> json) {
    return TechnicianService(
      serviceId: json['service_id'],
      customerId: json['customer_id'],
      installationId: json['installation_id'],
      serviceNumber: json['service_number'],
      serviceDate: json['service_date'],
    );
  }
}
