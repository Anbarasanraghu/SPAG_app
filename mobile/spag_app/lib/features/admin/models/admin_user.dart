class AdminUser {
  final int id;
  final String? name;   // ✅ nullable
  final String phone;
  final String role;

  AdminUser({
    required this.id,
    this.name,
    required this.phone,
    required this.role,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: (json['id'] as int?) ?? 0,
      name: json['name'], // can be null
      phone: (json['phone'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
    );
  }
}

