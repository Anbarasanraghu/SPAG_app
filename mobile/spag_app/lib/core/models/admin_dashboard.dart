class AdminDashboardStats {
  final int totalUsers;
  final int pendingServices;
  final int productRequests;
  final int activeNow;
  final int technicians;
  final double resolvedPercentage;
  final List<double> userGrowthData; // for the mini bar chart

  AdminDashboardStats({
    required this.totalUsers,
    required this.pendingServices,
    required this.productRequests,
    required this.activeNow,
    required this.technicians,
    required this.resolvedPercentage,
    required this.userGrowthData,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalUsers: json['total_users'] ?? 0,
      pendingServices: json['pending_services'] ?? 0,
      productRequests: json['product_requests'] ?? 0,
      activeNow: json['active_now'] ?? 0,
      technicians: json['technicians'] ?? 0,
      resolvedPercentage: (json['resolved_percentage'] ?? 0.0).toDouble(),
      userGrowthData: (json['user_growth_data'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ?? [],
    );
  }
}
