import 'package:flutter/material.dart';

import '../../core/models/app_version_model.dart';
import '../../core/services/app_version_service.dart';

/// Tracks whether a forced update or maintenance block is required, driving
/// the router's redirect to the matching full-screen page once it resolves.
class AppVersionController extends ChangeNotifier with WidgetsBindingObserver {
  AppVersionController(this._service);

  final AppVersionService _service;
  AppVersionService get versionService => _service;

  AppVersionModel? _config;
  AppVersionModel? get config => _config;

  bool forceUpdateRequired = false;
  bool maintenanceActive = false;

  /// Registers this controller as an app-lifecycle observer so maintenance
  /// (which can start or end while the app sits in the background) is
  /// re-checked the moment the user comes back to it, not just on
  /// [MaintenanceScreen]'s own polling timer.
  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> refresh() async {
    final config = await _service.fetchAppVersion();
    if (config == null) return;
    _config = config;

    var changed = false;

    final maintenance = config.maintenance.active && !config.maintenance.isReadOnly;
    if (maintenance != maintenanceActive) {
      maintenanceActive = maintenance;
      changed = true;
    }

    if (!forceUpdateRequired) {
      final required = await _service.shouldForceUpdate(config);
      if (required) {
        forceUpdateRequired = true;
        changed = true;
      }
    }

    if (changed) notifyListeners();
  }
}
