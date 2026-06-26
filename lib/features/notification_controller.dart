import 'package:flutter/material.dart';
import '../core/services/notification_sync_manager.dart';
import '../core/services/notification_sync_service.dart';

/// Controls notification preferences and delivery tracking.
class NotificationController extends ChangeNotifier {
  final NotificationSyncManager _manager = NotificationSyncManager.instance;

  /// Load all notification preferences.
  Future<void> load() async {
    await _manager.loadPreferences();
  }

  /// Get notification preference by type.
  Future<NotificationPreference?> getPreference(String type) async {
    return _manager.getPreference(type);
  }

  /// Update notification preference.
  Future<NotificationPreference?> updatePreference(
    String type,
    NotificationPreference preference,
  ) async {
    return _manager.updatePreference(type, preference);
  }

  /// Load delivery history.
  Future<void> loadDeliveryHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    await _manager.loadDeliveryHistory(
      startDate: startDate,
      endDate: endDate,
      status: status,
    );
  }

  /// Mark notification as read.
  Future<void> markAsRead(String notificationId) async {
    await _manager.markAsRead(notificationId);
  }

  /// Sync notifications.
  Future<void> syncNotifications() async {
    try {
      await _manager.syncNotifications();
    } catch (e) {
      debugPrint('Failed to sync notifications: $e');
      notifyListeners();
    }
  }

  /// Retry sync.
  Future<void> retrySyncNotifications() async {
    try {
      await _manager.retrySyncNotifications();
    } catch (e) {
      debugPrint('Retry sync failed: $e');
      notifyListeners();
    }
  }

  /// Register device for push notifications.
  Future<void> registerDevice(String deviceToken) async {
    await _manager.registerDevice(deviceToken);
  }

  /// Unregister device (on logout).
  Future<void> unregisterDevice(String deviceToken) async {
    await _manager.unregisterDevice(deviceToken);
  }

  /// Get preferences list.
  List<NotificationPreference>? get preferences => _manager.preferences;

  /// Get delivery history.
  List<NotificationDelivery>? get deliveryHistory => _manager.deliveryHistory;

  /// Get sync status.
  bool get isSyncing => _manager.isSyncing;
  String? get syncError => _manager.syncError;
  DateTime? get lastSync => _manager.lastSuccessfulSync;
  String get syncStatus => _manager.syncStatus;

  /// Clear all data (on logout).
  Future<void> clearAll() async {
    _manager.clearAll();
    notifyListeners();
  }
}
