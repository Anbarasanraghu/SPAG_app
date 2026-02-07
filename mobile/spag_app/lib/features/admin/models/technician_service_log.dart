class TechnicianServiceLog {
  final int serviceId;
  final String technicianName;
  final String customerName;
  final String status;
  final String serviceDate;

  TechnicianServiceLog({
    required this.serviceId,
    required this.technicianName,
    required this.customerName,
    required this.status,
    required this.serviceDate,
  });

  factory TechnicianServiceLog.fromJson(Map<String, dynamic> json) {
    return TechnicianServiceLog(
      serviceId: json['service_id'],
      technicianName: json['technician_name'] ?? 'Unknown',
      customerName: json['customer_name'] ?? 'Unknown',
      status: json['status'],
      serviceDate: json['service_date'],
    );
  }
}
