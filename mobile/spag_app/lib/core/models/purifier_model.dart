class PurifierModel {
  final int id;
  final String name;
  final int serviceIntervalDays;
  final int freeServices;
  final String? colours;
  final double? price;
  final String? features;
  final String? imageUrl;
  final String? category;
  final String? capacity;
  final String? descriptions;

  PurifierModel({
    required this.id,
    required this.name,
    required this.serviceIntervalDays,
    required this.freeServices,
    this.colours,
    this.price,
    this.features,
    this.imageUrl,
    this.category,
    this.capacity,
    this.descriptions,
  });

  factory PurifierModel.fromJson(Map<String, dynamic> json) {
    return PurifierModel(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      serviceIntervalDays: (json['service_interval_days'] as int?) ?? 0,
      freeServices: (json['free_services'] as int?) ?? 0,
      colours: json['colours'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      features: json['features'] as String?,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
      capacity: json['capacity'] as String?,
      descriptions: json['descriptions'] as String?,
    );
  }
}
