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
    return ServiceDetail(
      serviceId: json['service']['id'],
      serviceDate: json['service']['date'],
      serviceNumber: json['service']['number'],
      status: json['service']['status'],

      customerId: json['customer']['id'],
      customerName: json['customer']['name'],
      customerPhone: json['customer']['phone'],
      customerAddress: json['customer']['address'],

      installationId: json['product']['installation_id'],
      productModel: json['product']['model_name'],

      technicianId: json['technician']['id'],
      technicianName: json['technician']['name'],
      technicianPhone: json['technician']['phone'],
    );
  }
}
