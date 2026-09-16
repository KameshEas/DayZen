/// Service for notification preferences and delivery tracking sync.
///
/// API Bindings:
/// - BINDING 25: GET /notifications/preferences (getPreferences) - Batch all preferences
/// - BINDING 26: GET /notifications/preferences/{type} (getPreference) - REUSED 2-3x with per-type cache
/// - BINDING 27: PUT /notifications/preferences/{type} (updatePreference) - REUSED 4x per settings session
/// - BINDING 28: GET /notifications/delivery (getDeliveryHistory) - Date-range filtered
/// - BINDING 29: POST /notifications/{id}/read (markAsRead) - Single notification
/// - BINDING 30: POST /notifications/sync (syncNotifications) - Bulk refresh
/// - BINDING 31: POST /notifications/devices/register (registerDevice) - One-time registration
/// - BINDING 32: POST /notifications/devices/unregister (unregisterDevice) - One-time cleanup
library;

import '../api/api_client.dart';

/// Notification preference model.
class NotificationPreference {
  final String id;
  final String type; // task_reminder, journal_prompt, ai_suggestion, deadline_alert
  final bool enabled;
  final int? minHour; // Quiet hours start (24h format)
  final int? maxHour; // Quiet hours end
  final String? channel; // push, in_app, email
  final int advanceMinutes; // Minutes before event to notify
  final DateTime updatedAt;

  NotificationPreference({
    required this.id,
    required this.type,
    required this.enabled,
    this.minHour,
    this.maxHour,
    this.channel,
    required this.advanceMinutes,
    required this.updatedAt,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'notification',
      enabled: json['enabled'] as bool? ?? true,
      minHour: json['quiet_hours_start'] as int?,
      maxHour: json['quiet_hours_end'] as int?,
      channel: json['channel'] as String?,
      advanceMinutes: json['advance_minutes'] as int? ?? 15,
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'enabled': enabled,
        'quiet_hours_start': minHour,
        'quiet_hours_end': maxHour,
        'channel': channel,
        'advance_minutes': advanceMinutes,
      };
}

/// Notification delivery record.
class NotificationDelivery {
  final String id;
  final String notificationType;
  final String targetId; // task_id, entry_id, etc.
  final String title;
  final String message;
  final DateTime scheduledTime;
  final DateTime? deliveredTime;
  final String status; // scheduled, delivered, failed, read
  final String? failureReason;
  final int? clickedAt; // timestamp if user clicked

  NotificationDelivery({
    required this.id,
    required this.notificationType,
    required this.targetId,
    required this.title,
    required this.message,
    required this.scheduledTime,
    this.deliveredTime,
    required this.status,
    this.failureReason,
    this.clickedAt,
  });

  factory NotificationDelivery.fromJson(Map<String, dynamic> json) {
    return NotificationDelivery(
      id: json['id'] as String? ?? '',
      notificationType: json['notification_type'] as String? ?? 'notification',
      targetId: json['target_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Notification',
      message: json['message'] as String? ?? '',
      scheduledTime: DateTime.parse(json['scheduled_time'] as String? ?? DateTime.now().toIso8601String()),
      deliveredTime: json['delivered_time'] != null
          ? DateTime.parse(json['delivered_time'] as String? ?? DateTime.now().toIso8601String())
          : null,
      status: json['status'] as String? ?? 'scheduled',
      failureReason: json['failure_reason'] as String?,
      clickedAt: json['clicked_at'] as int?,
    );
  }
}

/// Service for notification sync operations.
class NotificationSyncService {
  NotificationSyncService._();

  static final NotificationSyncService _instance = NotificationSyncService._();

  static NotificationSyncService get instance => _instance;

  static final ApiClient _apiClient = ApiClient();

  // Cache
  final Map<String, NotificationPreference> _preferenceCache = {};
  final Map<String, NotificationDelivery> _deliveryCache = {};
  DateTime? _lastSyncTime;

  /// BINDING 25: Get all notification preferences.
  /// API: GET /notifications/preferences
  /// Cache: Preference cache (4h TTL)
  /// Used By: NotificationController.load()
  /// OPTIMIZATION: Batch load all preferences
  Future<List<NotificationPreference>> getPreferences() async {
    try {
      final response = await _apiClient.get('/notifications/preferences');
      final preferences = (response['preferences'] as List<dynamic>?)
          ?.map((p) => NotificationPreference.fromJson(p as Map<String, dynamic>))
          .toList() ?? [];

      // Cache all preferences by type
      for (final pref in preferences) {
        _preferenceCache[pref.type] = pref; // Cache by type for quick lookup

      }

      return preferences;
    } on ApiException {
      // Return cached preferences if available
      if (_preferenceCache.isNotEmpty) {
        return _preferenceCache.values.toList();
      }
      rethrow;
    }
  }

  /// BINDING 26: Get preference for specific notification type (REUSED - 2-3x)
  /// API: GET /notifications/preferences/{type}
  /// Cache: Per-type cache
  /// Used By:
  ///   1. NotificationController.getPreference() - Get specific
  ///   2. Settings UI (detail view for type)
  ///
  /// OPTIMIZATION: Check cache first, fall back to individual API
  Future<NotificationPreference?> getPreference(String type) async {
    try {
      // Check cache first (by type key)
      if (_preferenceCache.containsKey(type)) {
        return _preferenceCache[type];
      }

      // Check if in cache by looking through all
      for (final pref in _preferenceCache.values) {
        if (pref.type == type) {
          return pref;
        }
      }

      final response = await _apiClient.get('/notifications/preferences/$type');
      final pref = NotificationPreference.fromJson(response);
      _preferenceCache[pref.type] = pref; // Cache by type
      return pref;
    } on ApiException {
      return null;
    }
  }

  /// BINDING 27: Update notification preference (REUSED - 4x per settings session)
  /// API: PUT /notifications/preferences/{type}
  /// Cache: Invalidate after update
  /// Used By:
  ///   1. NotificationPreferencesCard (toggle)
  ///   2. Settings page (each preference toggle)
  ///   3. NotificationController.updatePreference()
  ///   4. Quiet hours configuration
  ///
  /// OPTIMIZATION: Individual updates vs batch
  Future<NotificationPreference> updatePreference(
    String type,
    NotificationPreference preference,
  ) async {
    try {
      final response = await _apiClient.put(
        '/notifications/preferences/$type',
        preference.toJson(),
      );
      final updated = NotificationPreference.fromJson(response);
      _preferenceCache[updated.type] = updated; // Update cache by type
      return updated;
    } on ApiException {
      rethrow;
    }
  }

  /// BINDING 28: Get notification delivery history.
  /// API: GET /notifications/delivery?start_date={}&end_date={}&status={}
  Future<List<NotificationDelivery>> getDeliveryHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    try {
      final params = <String, String>{};
      if (startDate != null) {
        params['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        params['end_date'] = endDate.toIso8601String();
      }
      if (status != null) {
        params['status'] = status;
      }

      String endpoint = '/notifications/delivery';
      if (params.isNotEmpty) {
        final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
        endpoint = '$endpoint?$queryString';
      }

      final response = await _apiClient.get(endpoint);
      final deliveries = (response['deliveries'] as List<dynamic>?)
          ?.map((d) => NotificationDelivery.fromJson(d as Map<String, dynamic>))
          .toList() ?? [];

      // Cache all deliveries
      for (final delivery in deliveries) {
        _deliveryCache[delivery.id] = delivery;
      }

      return deliveries;
    } on ApiException {
      // Return cached deliveries if available
      if (_deliveryCache.isNotEmpty) {
        return _deliveryCache.values.toList();
      }
      rethrow;
    }
  }

  /// BINDING 29: Mark notification as read.
  /// API: POST /notifications/{id}/read
  /// Cache: Update cache
  /// Used By: NotificationHistoryCard (mark as read)
  /// OPTIMIZATION: Simple POST, single item
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.post('/notifications/$notificationId/read', {});
      if (_deliveryCache.containsKey(notificationId)) {
        final cached = _deliveryCache[notificationId]!;
        _deliveryCache[notificationId] = NotificationDelivery(
          id: cached.id,
          notificationType: cached.notificationType,
          targetId: cached.targetId,
          title: cached.title,
          message: cached.message,
          scheduledTime: cached.scheduledTime,
          deliveredTime: cached.deliveredTime,
          status: 'read',
          failureReason: cached.failureReason,
          clickedAt: DateTime.now().millisecondsSinceEpoch,
        );
      }
    } on ApiException {
      rethrow;
    }
  }

  /// BINDING 30: Sync all notification data.
  /// API: POST /notifications/sync
  /// Used By: NotificationSyncManager.syncNotifications()
  /// OPTIMIZATION: Single call fetches all notification data
  Future<Map<String, dynamic>> syncNotifications() async {
    try {
      final response = await _apiClient.post('/notifications/sync', {
        'last_sync_at': _lastSyncTime?.toIso8601String(),
      });

      // Parse preferences
      final preferences = (response['preferences'] as List<dynamic>?)
          ?.map((p) => NotificationPreference.fromJson(p as Map<String, dynamic>))
          .toList() ?? [];

      // Parse delivery updates
      final deliveries = (response['delivery_updates'] as List<dynamic>?)
          ?.map((d) => NotificationDelivery.fromJson(d as Map<String, dynamic>))
          .toList() ?? [];

      // Cache all results
      for (final pref in preferences) {
        _preferenceCache[pref.id] = pref;
      }
      for (final delivery in deliveries) {
        _deliveryCache[delivery.id] = delivery;
      }

      _lastSyncTime = DateTime.now();

      return {
        'preferences': preferences,
        'deliveries': deliveries,
        'synced_at': DateTime.parse(response['synced_at'] as String),
      };
    } on ApiException {
      rethrow;
    }
  }

  /// BINDING 31: Register device for push notifications.
  /// API: POST /notifications/devices/register
  /// Cache: No cache (device management)
  /// Used By: NotificationController.registerDevice()
  /// OPTIMIZATION: One-time registration, refresh on token change
  /// Note: Essential for push notification delivery
  Future<void> registerDevice(String deviceToken) async {
    try {
      await _apiClient.post('/notifications/devices/register', {
        'device_token': deviceToken,
        'platform': 'flutter',
      });
    } on ApiException {
      rethrow;
    }
  }

  /// BINDING 32: Unregister device.
  /// API: POST /notifications/devices/unregister
  /// Cache: No cache (device cleanup)
  /// Used By: NotificationController.unregisterDevice()
  /// OPTIMIZATION: One-time cleanup
  /// Note: Prevents notifications to old device
  Future<void> unregisterDevice(String deviceToken) async {
    try {
      await _apiClient.post('/notifications/devices/unregister', {
        'device_token': deviceToken,
      });
    } on ApiException {
      rethrow;
    }
  }

  /// Get last sync time.
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Clear cache (on logout).
  void clearCache() {
    _preferenceCache.clear();
    _deliveryCache.clear();
    _lastSyncTime = null;
  }

  /// Get error message.
  static String getErrorMessage(ApiException exception) {
    return ApiClient.getUserErrorMessage(exception);
  }
}
