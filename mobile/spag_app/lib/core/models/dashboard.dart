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
      serviceNumber: (json['serviceNumber'] ?? json['service_number'] ?? 0) as int,
      serviceDate: (json['serviceDate'] ?? json['service_date'] ?? '').toString(),
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
  final bool profileCompleted;

  CustomerDashboard({
    required this.customerId,
    required this.purifierModel,
    required this.installDate,
    this.nextServiceDate,
    required this.services,
    this.profileCompleted = true,
  });

  factory CustomerDashboard.fromJson(Map<String, dynamic> json) {
    // Handle two possible shapes coming from backend:
    // 1) { customerId, purifierModel, installDate, nextServiceDate, services }
    // 2) { installations: [{ id, purifierModel, installDate }], services: [...] }
    try {
      // Log incoming JSON for debugging
      debugPrint('========== DASHBOARD PARSING START ==========');
      debugPrint('Full JSON: $json');
      debugPrint('JSON Keys: ${json.keys.toList()}');
      
      final servicesPreview = (json['services'] ?? []) as List;
      debugPrint('Services array found: ${servicesPreview.isNotEmpty}');
      debugPrint('Parsed services count: ${servicesPreview.length}');
      if (servicesPreview.isNotEmpty) {
        debugPrint('Services preview: $servicesPreview');
      }

      if (json.containsKey('installations')) {
        final installations = (json['installations'] ?? []) as List;
        final servicesList = (json['services'] ?? []) as List;

        if (installations.isEmpty) {
          return CustomerDashboard(
            customerId: (json['customer_id'] ?? json['customerId'] ?? 0) as int,
            purifierModel: '',
            installDate: '',
            nextServiceDate: (json['next_service_date'] ?? json['nextServiceDate'])?.toString(),
            services: servicesList.map((e) => ServiceItem.fromJson(e as Map<String, dynamic>)).toList(),
            profileCompleted: (json['profile_completed'] ?? true) as bool,
          );
        } else {
          final inst = (installations.first ?? {}) as Map<String, dynamic>;
          return CustomerDashboard(
            customerId: (inst['id'] ?? inst['customerId'] ?? 0) as int,
            purifierModel: (inst['purifier_model'] ?? inst['purifierModel'] ?? '')?.toString() ?? '',
            installDate: (inst['install_date'] ?? inst['installDate'] ?? '')?.toString() ?? '',
            nextServiceDate: (json['next_service_date'] ?? json['nextServiceDate'])?.toString(),
            services: servicesList.map((e) => ServiceItem.fromJson(e as Map<String, dynamic>)).toList(),
            profileCompleted: (json['profile_completed'] ?? true) as bool,
          );
        }
      }

      final servicesList = (json['services'] ?? []) as List;
      debugPrint('Parsed servicesList length: ${servicesList.length}');

      // Parse camelCase fields from API
      final customerId = (json['customerId'] ?? json['customer_id'] ?? 0) as int;
      final purifierModel = (json['purifierModel'] ?? json['purifier_model'] ?? '')?.toString() ?? '';
      final installDate = (json['installDate'] ?? json['install_date'] ?? '')?.toString() ?? '';
      
      debugPrint('Parsed values: customerId=$customerId, purifierModel=$purifierModel, installDate=$installDate');
      debugPrint('Services parsed: ${servicesList.length}');
      
      final dashboard = CustomerDashboard(
        customerId: customerId,
        purifierModel: purifierModel,
        installDate: installDate,
        nextServiceDate: (json['nextServiceDate'] ?? json['next_service_date'])?.toString(),
        services: servicesList.map((e) {
          final item = ServiceItem.fromJson(e as Map<String, dynamic>);
          debugPrint('  Service: #${item.serviceNumber} - ${item.serviceDate} (${item.status})');
          return item;
        }).toList(),
        profileCompleted: (json['profile_completed'] ?? true) as bool,
      );
      
      debugPrint('========== DASHBOARD PARSING END ==========');
      return dashboard;
    } catch (e) {
      debugPrint('========== DASHBOARD PARSING ERROR ==========');
      debugPrint('Error: $e');
      debugPrint('=======================================');
      throw Exception('Failed to parse CustomerDashboard: $e');
    }
  }
}
