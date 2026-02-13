class ServiceStatusLog {
  final int id;
  final int serviceId;
  final String? oldStatus;
  final String newStatus;
  final String changedAt;
  final int? changedBy;

  ServiceStatusLog({
    required this.id,
    required this.serviceId,
    this.oldStatus,
    required this.newStatus,
    required this.changedAt,
    this.changedBy,
  });

  factory ServiceStatusLog.fromJson(Map<String, dynamic> json) {
    return ServiceStatusLog(
      id: json['id'] as int,
      serviceId: json['service_id'] as int,
      oldStatus: json['old_status'] as String?,
      newStatus: json['new_status'] as String? ?? '',
      changedAt: json['changed_at']?.toString() ?? '',
      changedBy: json['changed_by'] as int?,
    );
  }
}
