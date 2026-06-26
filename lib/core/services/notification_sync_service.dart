/// Service for notification preferences and delivery tracking sync.
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
      id: json['id'] as String,
      type: json['type'] as String,
      enabled: json['enabled'] as bool? ?? true,
      minHour: json['quiet_hours_start'] as int?,
      maxHour: json['quiet_hours_end'] as int?,
      channel: json['channel'] as String?,
      advanceMinutes: json['advance_minutes'] as int? ?? 15,
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      id: json['id'] as String,
      notificationType: json['notification_type'] as String,
      targetId: json['target_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      deliveredTime: json['delivered_time'] != null
          ? DateTime.parse(json['delivered_time'] as String)
          : null,
      status: json['status'] as String,
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

  /// Get all notification preferences.
  Future<List<NotificationPreference>> getPreferences() async {
    try {
      final response = await _apiClient.get('/notifications/preferences');
      final preferences = (response['preferences'] as List<dynamic>?)
          ?.map((p) => NotificationPreference.fromJson(p as Map<String, dynamic>))
          .toList() ?? [];

      // Cache all preferences
      for (final pref in preferences) {
        _preferenceCache[pref.id] = pref;
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

  /// Get preference for specific notification type.
  Future<NotificationPreference?> getPreference(String type) async {
    try {
      // Check cache first
      for (final pref in _preferenceCache.values) {
        if (pref.type == type) {
          return pref;
        }
      }

      final response = await _apiClient.get('/notifications/preferences/$type');
      final pref = NotificationPreference.fromJson(response);
      _preferenceCache[pref.id] = pref;
      return pref;
    } on ApiException {
      return null;
    }
  }

  /// Update notification preference.
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
      _preferenceCache[updated.id] = updated;
      return updated;
    } on ApiException {
      rethrow;
    }
  }

  /// Get notification delivery history.
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

  /// Mark notification as read.
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

  /// Sync all notification data.
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

  /// Register device for push notifications.
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

  /// Unregister device (on logout).
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
