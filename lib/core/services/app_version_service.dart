/// Fetches remote app-version config and decides whether a forced update
/// is required for the current install.
library;

import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../api/api_client.dart';
import '../models/app_version_model.dart';
import 'analytics_service.dart';

class AppVersionService {
  AppVersionService(this._apiClient, this._analyticsService);

  final ApiClient _apiClient;
  final AnalyticsService _analyticsService;

  String getPlatformName() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  /// Fetches `/app-version` for this platform/installed version.
  /// Fails open (returns null) on any network/parse error — a broken
  /// remote config must never block the app.
  Future<AppVersionModel?> fetchAppVersion() async {
    try {
      final platform = getPlatformName();
      if (platform != 'android' && platform != 'ios') return null;

      final packageInfo = await PackageInfo.fromPlatform();
      final response = await _apiClient.publicGet(
        '/app-version?platform=$platform&version=${packageInfo.version}',
      );
      return AppVersionModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  /// Returns true if `current < minimum`, e.g. isVersionOutdated('1.0.0', '1.0.1') -> true.
  bool isVersionOutdated(String currentVersion, String minimumVersion) {
    try {
      final current = _parseVersion(currentVersion);
      final minimum = _parseVersion(minimumVersion);

      if (current[0] != minimum[0]) return current[0] < minimum[0];
      if (current[1] != minimum[1]) return current[1] < minimum[1];
      return current[2] < minimum[2];
    } catch (_) {
      return false;
    }
  }

  List<int> _parseVersion(String version) {
    try {
      final cleanVersion = version.split('+').first;
      final parts = cleanVersion.split('.').map(int.parse).toList();
      while (parts.length < 3) {
        parts.add(0);
      }
      return parts.sublist(0, 3);
    } catch (_) {
      return [0, 0, 0];
    }
  }

  /// Deterministic rollout bucketing hashed from the package/bundle id, so
  /// the same install always gets the same rollout decision.
  Future<bool> isEligibleForRollout(int rolloutPercentage) async {
    if (rolloutPercentage >= 100) return true;
    if (rolloutPercentage <= 0) return false;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final hash = _hashString(packageInfo.packageName).abs() % 100;
      return hash < rolloutPercentage;
    } catch (_) {
      return Random().nextInt(100) < rolloutPercentage;
    }
  }

  int _hashString(String str) {
    int hash = 0;
    for (int i = 0; i < str.length; i++) {
      final char = str.codeUnitAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return hash;
  }

  Future<bool> shouldForceUpdate(AppVersionModel config) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!isVersionOutdated(packageInfo.version, config.minimumVersion)) {
        return false;
      }

      final eligible = await isEligibleForRollout(config.rolloutPercentage);
      if (!eligible) return false;

      await _analyticsService.logEvent('force_update_required', parameters: {
        'current_version': packageInfo.version,
        'minimum_version': config.minimumVersion,
        'platform': getPlatformName(),
        'rollout_percentage': config.rolloutPercentage,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logUpdateInitiated(String minimumVersion) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      await _analyticsService.logEvent('force_update_initiated', parameters: {
        'current_version': packageInfo.version,
        'minimum_version': minimumVersion,
        'platform': getPlatformName(),
      });
    } catch (_) {
      // Best-effort analytics only.
    }
  }

  Future<void> logRedirectedToStore() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      await _analyticsService.logEvent('user_redirected_to_store', parameters: {
        'current_version': packageInfo.version,
        'platform': getPlatformName(),
      });
    } catch (_) {
      // Best-effort analytics only.
    }
  }
}
