class TechnicianServiceLog {
  final int id;
  final int customerId;
  final int installationId;
  final int serviceNumber;
  final String status;
  final String serviceDate;
  final String? technicianName;
  final String? customerName;

  TechnicianServiceLog({
    required this.id,
    required this.customerId,
    required this.installationId,
    required this.serviceNumber,
    required this.status,
    required this.serviceDate,
    this.technicianName,
    this.customerName,
  });

  factory TechnicianServiceLog.fromJson(Map<String, dynamic> json) {
    return TechnicianServiceLog(
      id: json['id'],
      customerId: json['customer_id'],
      installationId: json['installation_id'],
      serviceNumber: json['service_number'],
      status: json['status'],
      serviceDate: json['service_date'],
      technicianName: json['technician_name'] ?? json['assigned_to'],
      customerName: json['customer_name'],
    );
  }
}
