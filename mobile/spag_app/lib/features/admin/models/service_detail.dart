class ServiceDetail {
  final int serviceId;
  final String serviceDate;
  final int serviceNumber;
  final String status;

  final int customerId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;

  final int installationId;
  final String productModel;

  final int? technicianId;
  final String? technicianName;
  final String? technicianPhone;

  ServiceDetail({
    required this.serviceId,
    required this.serviceDate,
    required this.serviceNumber,
    required this.status,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.installationId,
    required this.productModel,
    this.technicianId,
    this.technicianName,
    this.technicianPhone,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    // Defensive parsing: handle missing keys gracefully
    final service = json['service'] as Map<String, dynamic>? ?? {};
    final customer = json['customer'] as Map<String, dynamic>? ?? {};
    final product = json['product'] as Map<String, dynamic>? ?? {};
    final technician = json['technician'] as Map<String, dynamic>?;

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    String safeString(dynamic v) => v == null ? '' : v.toString();

    return ServiceDetail(
      serviceId: parseInt(service['id']) ?? 0,
      serviceDate: safeString(service['date']),
      serviceNumber: parseInt(service['number']) ?? 0,
      status: safeString(service['status']),

      customerId: parseInt(customer['id']) ?? 0,
      customerName: safeString(customer['name']),
      customerPhone: safeString(customer['phone']),
      customerAddress: safeString(customer['address'] is Map ? (customer['address']['line1'] ?? '') : customer['address']),

      installationId: parseInt(product['installation_id']) ?? 0,
      productModel: safeString(product['model_name']),

      technicianId: parseInt(technician?['id']),
      technicianName: technician != null ? safeString(technician['name']) : null,
      technicianPhone: technician != null ? safeString(technician['phone']) : null,
    );
  }
}
