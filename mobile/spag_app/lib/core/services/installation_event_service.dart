import 'package:flutter/foundation.dart';

/// Global event service for installation completion notifications
/// Allows different screens to listen for installation updates across the app
class InstallationEventService {
  static final InstallationEventService _instance =
      InstallationEventService._internal();

  factory InstallationEventService() {
    return _instance;
  }

  InstallationEventService._internal();

  /// ValueNotifier to broadcast installation completion events
  static final ValueNotifier<int?> _installationCompleted =
      ValueNotifier<int?>(null);

  /// Listen to installation completion events
  static ValueNotifier<int?> get installationCompletedNotifier =>
      _installationCompleted;

  /// Notify all listeners that an installation was completed
  static void notifyInstallationCompleted(int requestId) {
    debugPrint('[InstallationEventService] Installation $requestId completed');
    _installationCompleted.value = requestId;
  }

  /// Clear the notification
  static void clearNotification() {
    _installationCompleted.value = null;
  }
}
