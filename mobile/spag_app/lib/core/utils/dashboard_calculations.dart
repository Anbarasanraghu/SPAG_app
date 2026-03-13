class DashboardCalculations {
  static String calculateGrowthRate(int currentValue, int previousValue) {
    if (previousValue == 0) return '+0%';
    final growth = ((currentValue - previousValue) / previousValue * 100).round();
    return growth >= 0 ? '+$growth%' : '$growth%';
  }

  static String calculatePendingTrend(int currentPending, int previousPending) {
    if (previousPending == 0) return '0 today';
    final change = currentPending - previousPending;
    return change <= 0 ? '${change.abs()} today' : '+${change.abs()} today';
  }

  static String formatUserCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  static double calculateTechnicianUtilization(int activeTechs, int totalTechs) {
    if (totalTechs == 0) return 0.0;
    return (activeTechs / totalTechs) * 100;
  }

  static String getActivityStatus(int activeUsers, int totalUsers) {
    if (totalUsers == 0) return 'No Activity';
    final ratio = activeUsers / totalUsers;
    if (ratio >= 0.3) return 'High Activity';
    if (ratio >= 0.1) return 'Moderate Activity';
    return 'Low Activity';
  }

  static List<double> generateGrowthChart(List<double> data, int periods) {
    if (data.isEmpty) {
      return List.generate(periods, (i) => 20.0 + (i * 5.0));
    }

    // Ensure we have enough data points
    while (data.length < periods) {
      data.add(data.isNotEmpty ? data.last : 20.0);
    }

    // Normalize to chart height (max 50)
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return data;

    return data.map((val) => (val / maxVal) * 50).toList();
  }
}