import 'package:flutter/foundation.dart';

import '../../core/models/app_version_model.dart';
import '../../core/services/app_version_service.dart';

/// Tracks whether a forced update is required, driving the router's
/// redirect to the update-showcase screen once it resolves.
class AppVersionController extends ChangeNotifier {
  AppVersionController(this._service);

  final AppVersionService _service;
  AppVersionService get versionService => _service;

  AppVersionModel? _config;
  AppVersionModel? get config => _config;

  bool forceUpdateRequired = false;

  Future<void> checkForUpdate() async {
    final config = await _service.fetchAppVersion();
    if (config == null) return;

    _config = config;
    final required = await _service.shouldForceUpdate(config);
    if (required && !forceUpdateRequired) {
      forceUpdateRequired = true;
      notifyListeners();
    }
  }
}
