class PendingService {
  final int serviceId;
  final String serviceDate;
  final int serviceNumber;
  final String status;
  final String customerName;
  final int? technicianId;
  final String? technicianName;

  PendingService({
    required this.serviceId,
    required this.serviceDate,
    required this.serviceNumber,
    required this.status,
    required this.customerName,
    this.technicianId,
    this.technicianName,
  });

  factory PendingService.fromJson(Map<String, dynamic> json) {
    return PendingService(
      serviceId: json['service_id'],
      serviceDate: json['service_date'],
      serviceNumber: json['service_number'],
      status: json['status'],
      customerName: json['customer_name'] ?? "Unknown",
      technicianId: json['technician_id'],
      technicianName: json['technician_name'],
    );
  }
}
