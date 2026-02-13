class TechnicianActivityLog {
  final int id;
  final int technicianId;
  final int? serviceId;
  final String action;
  final String createdAt;

  TechnicianActivityLog({
    required this.id,
    required this.technicianId,
    this.serviceId,
    required this.action,
    required this.createdAt,
  });

  factory TechnicianActivityLog.fromJson(Map<String, dynamic> json) {
    return TechnicianActivityLog(
      id: json['id'] as int,
      technicianId: json['technician_id'] as int,
      serviceId: json['service_id'] as int?,
      action: json['action'] as String? ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
