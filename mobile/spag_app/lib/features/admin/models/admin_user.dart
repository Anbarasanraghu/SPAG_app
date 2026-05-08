class AdminUser {
  final int id;
  final String? name;   // ✅ nullable
  final String phone;
  final String? email;  // ✅ nullable
  final String role;
  final bool profileCompleted;

  AdminUser({
    required this.id,
    this.name,
    required this.phone,
    this.email,
    required this.role,
    this.profileCompleted = false,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: (json['id'] as int?) ?? 0,
      name: json['name'], // can be null
      phone: (json['phone'] as String?) ?? '',
      email: json['email'] as String?,
      role: (json['role'] as String?) ?? '',
      profileCompleted: (json['profile_completed'] as bool?) ?? false,
    );
  }
}

