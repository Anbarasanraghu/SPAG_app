class ServiceItem {
  final int serviceNumber;
  final String serviceDate;
  final String status;

  ServiceItem({
    required this.serviceNumber,
    required this.serviceDate,
    required this.status,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      serviceNumber: json['service_number'],
      serviceDate: json['service_date'],
      status: json['status'],
    );
  }
}

class CustomerDashboard {
  final int customerId;
  final String purifierModel;
  final String installDate;
  final String? nextServiceDate;
  final List<ServiceItem> services;

  CustomerDashboard({
    required this.customerId,
    required this.purifierModel,
    required this.installDate,
    this.nextServiceDate,
    required this.services,
  });

  factory CustomerDashboard.fromJson(Map<String, dynamic> json) {
    return CustomerDashboard(
      customerId: json['customer_id'],
      purifierModel: json['purifier_model'],
      installDate: json['install_date'],
      nextServiceDate: json['next_service_date'],
      services: (json['services'] as List)
          .map((e) => ServiceItem.fromJson(e))
          .toList(),
    );
  }
}
