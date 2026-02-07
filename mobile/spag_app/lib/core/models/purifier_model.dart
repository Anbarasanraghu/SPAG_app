class PurifierModel {
  final int id;
  final String name;
  final int serviceIntervalDays;
  final int freeServices;

  PurifierModel({
    required this.id,
    required this.name,
    required this.serviceIntervalDays,
    required this.freeServices,
  });

  factory PurifierModel.fromJson(Map<String, dynamic> json) {
    return PurifierModel(
      id: json['id'],
      name: json['name'],
      serviceIntervalDays: json['service_interval_days'],
      freeServices: json['free_services'],
    );
  }
}