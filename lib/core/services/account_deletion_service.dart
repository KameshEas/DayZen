import '../api/api_client.dart';
import '../logging/app_logger.dart';

/// Why an account deletion didn't happen. In every case the server still
/// has the account and nothing on the device was touched.
enum AccountDeletionFailure {
  /// No connection or the request timed out.
  offline,

  /// The session is no longer valid; the user must sign in again first.
  sessionExpired,

  /// Too many attempts in the last hour (HTTP 429).
  rateLimited,

  /// Any other server error.
  server,
}

class AccountDeletionException implements Exception {
  const AccountDeletionException(this.reason);

  final AccountDeletionFailure reason;

  /// Calm, user-facing explanation.
  String get message => switch (reason) {
        AccountDeletionFailure.offline =>
          "Couldn't reach DayZen. Nothing was deleted. Check your connection and try again.",
        AccountDeletionFailure.sessionExpired =>
          'Your session has expired. Sign in again, then delete your account.',
        AccountDeletionFailure.rateLimited =>
          'Too many attempts. Please try again in an hour.',
        AccountDeletionFailure.server =>
          'Something went wrong on our side. Nothing was deleted. Please try again later.',
      };

  @override
  String toString() => 'AccountDeletionException($reason)';
}

/// Permanently deletes the user's DayZen account (`DELETE /users/me`),
/// then removes everything this device holds for it.
///
/// Order matters:
/// 1. Delete on the server. If this fails, nothing local is touched and an
///    [AccountDeletionException] is thrown.
/// 2. Sign out, so no background sync can push local data back up.
/// 3. Wipe local data (tasks, journal, notifications, PIN, preferences).
///
/// Steps 2 and 3 run even if one of them throws: the account is already
/// gone, so the user must not see an error for it. Failures are logged.
class AccountDeletionService {
  AccountDeletionService({
    required ApiClient api,
    required Future<void> Function() signOut,
    required Future<void> Function() wipeLocalData,
  })  : _api = api,
        _signOut = signOut,
        _wipeLocalData = wipeLocalData;

  static const String endpoint = '/users/me';

  final ApiClient _api;
  final Future<void> Function() _signOut;
  final Future<void> Function() _wipeLocalData;

  Future<void> deleteAccount() async {
    try {
      await _api.delete(endpoint);
    } on ApiException catch (e) {
      throw AccountDeletionException(_reasonFor(e));
    }

    for (final step in [_signOut, _wipeLocalData]) {
      try {
        await step();
      } catch (e) {
        AppLogger.debug('Account deleted, but local cleanup step failed: $e');
      }
    }
  }

  static AccountDeletionFailure _reasonFor(ApiException e) {
    if (e.statusCode == 429) return AccountDeletionFailure.rateLimited;
    return switch (e.errorType) {
      ApiErrorType.networkError => AccountDeletionFailure.offline,
      ApiErrorType.authenticationError => AccountDeletionFailure.sessionExpired,
      _ => AccountDeletionFailure.server,
    };
  }
}
