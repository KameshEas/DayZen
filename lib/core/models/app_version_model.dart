/// App version / remote-config model for the `/app-version` endpoint.
///
/// Backed by the admin service's app-config, itself configured through the
/// Aspire Helm deployment — see `aspired2d-services/services/dayzen/app/routes/app_version.py`.
library;

/// Maintenance details computed server-side (the device clock is never
/// trusted: [active] already accounts for the schedule and tester bypass).
class MaintenanceInfo {
  const MaintenanceInfo({
    this.active = false,
    this.isReadOnly = false,
    this.title,
    this.message,
    this.endsAt,
    this.retryAfterSeconds = 60,
    this.statusUrl,
  });

  factory MaintenanceInfo.fromJson(Map<String, dynamic> data) {
    final retry = (data['retryAfterSeconds'] as num?)?.toInt() ?? 60;
    return MaintenanceInfo(
      active: data['active'] as bool? ?? false,
      isReadOnly: data['type'] == 'read_only',
      title: data['title'] as String?,
      message: data['message'] as String?,
      endsAt: DateTime.tryParse(data['endsAt'] as String? ?? ''),
      retryAfterSeconds: retry.clamp(15, 3600),
      statusUrl: data['statusUrl'] as String?,
    );
  }

  final bool active;
  final bool isReadOnly;
  final String? title;
  final String? message;
  final DateTime? endsAt;
  final int retryAfterSeconds;
  final String? statusUrl;
}

/// One live announcement, already chosen and ordered by the backend. Not
/// consumed by DayZen yet — parsed so the model never chokes on the full
/// payload the backend always sends.
class AnnouncementInfo {
  const AnnouncementInfo({
    required this.id,
    required this.body,
    this.title,
  });

  factory AnnouncementInfo.fromJson(Map<String, dynamic> data) {
    return AnnouncementInfo(
      id: data['id'] as String? ?? '',
      body: data['body'] as String? ?? '',
      title: data['title'] as String?,
    );
  }

  final String id;
  final String body;
  final String? title;
}

/// App version config for the forced-update flow.
class AppVersionModel {
  const AppVersionModel({
    required this.minimumVersion,
    required this.currentVersion,
    required this.releaseNotes,
    required this.rolloutPercentage,
    required this.storeUrl,
    this.forceUpdate = false,
    this.maintenance = const MaintenanceInfo(),
    this.announcements = const [],
    this.featureFlags = const {},
  });

  /// Parses the backend's `GET /app-version` response.
  factory AppVersionModel.fromJson(Map<String, dynamic> data) {
    final maintenanceJson = data['maintenance'];
    final announcementsJson = data['announcements'];
    return AppVersionModel(
      minimumVersion: data['minimumVersion'] as String? ?? '0.0.0',
      currentVersion: data['currentVersion'] as String? ?? '0.0.0',
      releaseNotes: data['releaseNotes'] as String? ?? '',
      rolloutPercentage: (data['rolloutPercentage'] as num?)?.toInt() ?? 100,
      storeUrl: data['storeUrl'] as String? ?? '',
      forceUpdate: data['forceUpdate'] as bool? ?? false,
      maintenance: maintenanceJson is Map<String, dynamic>
          ? MaintenanceInfo.fromJson(maintenanceJson)
          : const MaintenanceInfo(),
      announcements: announcementsJson is List
          ? announcementsJson
              .whereType<Map<String, dynamic>>()
              .map(AnnouncementInfo.fromJson)
              .where((a) => a.id.isNotEmpty && a.body.isNotEmpty)
              .toList()
          : const [],
      featureFlags: (data['featureFlags'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value == true),
          ) ??
          const {},
    );
  }

  final String minimumVersion;
  final String currentVersion;
  final String releaseNotes;
  final int rolloutPercentage;
  final String storeUrl;
  final bool forceUpdate;
  final MaintenanceInfo maintenance;
  final List<AnnouncementInfo> announcements;
  final Map<String, bool> featureFlags;
}
