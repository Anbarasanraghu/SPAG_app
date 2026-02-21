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
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      serviceIntervalDays: (json['service_interval_days'] as int?) ?? 0,
      freeServices: (json['free_services'] as int?) ?? 0,
    );
  }
}