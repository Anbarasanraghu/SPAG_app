import 'package:flutter/foundation.dart';

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
      serviceNumber: (json['service_number'] ?? 0) as int,
      serviceDate: (json['service_date'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
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
    // Handle two possible shapes coming from backend:
    // 1) { customer_id, purifier_model, install_date, next_service_date, services }
    // 2) { installations: [{ id, purifier_model, install_date }], services: [...] }
    try {
      // Log incoming JSON for debugging
      // ignore: avoid_print
      debugPrint('Parsing CustomerDashboard JSON: $json');
      final servicesPreview = (json['services'] ?? []) as List;
      debugPrint('Parsed services count: ${servicesPreview.length}, services: $servicesPreview');

      if (json.containsKey('installations')) {
        final installations = (json['installations'] ?? []) as List;
        final servicesList = (json['services'] ?? []) as List;

        if (installations.isEmpty) {
          return CustomerDashboard(
            customerId: (json['customer_id'] ?? 0) as int,
            purifierModel: '',
            installDate: '',
            nextServiceDate: json['next_service_date']?.toString(),
            services: servicesList.map((e) => ServiceItem.fromJson(e as Map<String, dynamic>)).toList(),
          );
        } else {
          final inst = (installations.first ?? {}) as Map<String, dynamic>;
          return CustomerDashboard(
            customerId: (inst['id'] ?? 0) as int,
            purifierModel: (inst['purifier_model'] ?? '')?.toString() ?? '',
            installDate: (inst['install_date'] ?? '')?.toString() ?? '',
            nextServiceDate: json['next_service_date']?.toString(),
            services: servicesList.map((e) => ServiceItem.fromJson(e as Map<String, dynamic>)).toList(),
          );
        }
      }

      final servicesList = (json['services'] ?? []) as List;
      debugPrint('Parsed servicesList length: ${servicesList.length}');

      return CustomerDashboard(
        customerId: (json['customer_id'] ?? 0) as int,
        purifierModel: (json['purifier_model'] ?? '')?.toString() ?? '',
        installDate: (json['install_date'] ?? '')?.toString() ?? '',
        nextServiceDate: json['next_service_date']?.toString(),
        services: servicesList.map((e) => ServiceItem.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      throw Exception('Failed to parse CustomerDashboard: $e');
    }
  }
}
