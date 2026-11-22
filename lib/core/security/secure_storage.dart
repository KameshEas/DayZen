import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The one secure-storage configuration for the whole app (P1-6).
///
/// The app used to have two configs: AppPrefs (PIN) used
/// `encryptedSharedPreferences: true`, JwtAuthService (session) used the
/// default. On Android both write the same "FlutterSecureStorage" file, and
/// every call made with the encrypted config runs flutter_secure_storage's
/// `checkAndMigrateToEncrypted`, which moves all plain entries into the
/// encrypted store. So the session was written plain, migrated into the
/// encrypted store the next time the PIN was read, and from then on the
/// session's own config could neither read nor delete it: sign-out left the
/// encrypted session on disk (verified on a device).
///
/// One config fixes that. Existing installs need no migration code: the
/// first call with this config runs the same automatic migration, which
/// moves any plain session entries into the encrypted store where this
/// config reads them.
const FlutterSecureStorage appSecureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);
