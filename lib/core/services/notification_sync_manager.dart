/// Manages notification preferences and delivery tracking sync.
library;

import 'package:flutter/foundation.dart';
import 'notification_sync_service.dart';

/// Handles notification sync coordination.
class NotificationSyncManager extends ChangeNotifier {
  NotificationSyncManager._();

  static final NotificationSyncManager _instance = NotificationSyncManager._();

  static NotificationSyncManager get instance => _instance;

  static final NotificationSyncService _service = NotificationSyncService.instance;

  bool _isSyncing = false;
  DateTime? _lastSuccessfulSync;
  String? _syncError;

  // Cached data
  List<NotificationPreference>? _preferences;
  List<NotificationDelivery>? _deliveryHistory;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;
  String? get syncError => _syncError;

  List<NotificationPreference>? get preferences => _preferences;
  List<NotificationDelivery>? get deliveryHistory => _deliveryHistory;

  /// Load notification preferences.
  Future<void> loadPreferences() async {
    try {
      _preferences = await _service.getPreferences();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load preferences: $e');
      notifyListeners();
    }
  }

  /// Get preference for specific type.
  Future<NotificationPreference?> getPreference(String type) async {
    try {
      return await _service.getPreference(type);
    } catch (e) {
      debugPrint('Failed to get preference: $e');
      return null;
    }
  }

  /// Update preference.
  Future<NotificationPreference?> updatePreference(
    String type,
    NotificationPreference preference,
  ) async {
    try {
      final updated = await _service.updatePreference(type, preference);
      // Reload preferences after update
      await loadPreferences();
      return updated;
    } catch (e) {
      debugPrint('Failed to update preference: $e');
      notifyListeners();
      return null;
    }
  }

  /// Load delivery history.
  Future<void> loadDeliveryHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    try {
      _deliveryHistory = await _service.getDeliveryHistory(
        startDate: startDate,
        endDate: endDate,
        status: status,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load delivery history: $e');
      notifyListeners();
    }
  }

  /// Mark notification as read.
  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to mark as read: $e');
    }
  }

  /// Sync all notification data.
  Future<void> syncNotifications() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      final result = await _service.syncNotifications();

      _preferences = result['preferences'] as List<NotificationPreference>;
      _deliveryHistory = result['deliveries'] as List<NotificationDelivery>;

      _lastSuccessfulSync = DateTime.now();
      _syncError = null;
      debugPrint('Notification sync successful at $_lastSuccessfulSync');
    } catch (e) {
      _syncError = e.toString();
      debugPrint('Notification sync failed: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Manual retry sync.
  Future<void> retrySyncNotifications() async {
    try {
      await syncNotifications();
    } catch (e) {
      debugPrint('Notification sync retry failed: $e');
      rethrow;
    }
  }

  /// Register device token for push notifications.
  Future<void> registerDevice(String deviceToken) async {
    try {
      await _service.registerDevice(deviceToken);
    } catch (e) {
      debugPrint('Failed to register device: $e');
    }
  }

  /// Unregister device token (on logout).
  Future<void> unregisterDevice(String deviceToken) async {
    try {
      await _service.unregisterDevice(deviceToken);
    } catch (e) {
      debugPrint('Failed to unregister device: $e');
    }
  }

  /// Clear all data (on logout).
  void clearAll() {
    _preferences = null;
    _deliveryHistory = null;
    _lastSuccessfulSync = null;
    _syncError = null;
    _isSyncing = false;
  }

  /// Get sync status for UI.
  String get syncStatus {
    if (_isSyncing) return 'Syncing notifications...';
    if (_syncError != null) return 'Sync error';
    if (_lastSuccessfulSync == null) return 'Not synced';

    final minutesAgo = DateTime.now().difference(_lastSuccessfulSync!).inMinutes;
    if (minutesAgo == 0) return 'Just now';
    if (minutesAgo < 60) return '$minutesAgo min ago';

    final hoursAgo = (minutesAgo / 60).floor();
    if (hoursAgo < 24) return '$hoursAgo h ago';

    final daysAgo = (hoursAgo / 24).floor();
    return '$daysAgo d ago';
  }
}
