import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The app must not call API paths the DayZen
/// service doesn't serve. It used to call about ten (/ai/*, /insights/*,
/// /achievements, GET /journal/{id}) that all failed silently.
///
/// Scans the API code for path literals and checks each against
/// [serverPaths], a copy of the routes in aspired2d-services
/// services/dayzen/app/routes (prefix /api/v1/dayzen). When the server gains
/// or loses a route, update this list in the same change.
const serverPaths = <String>{
  '/auth/login',
  '/auth/register',
  '/auth/refresh',
  '/auth/logout',
  '/auth/forgot-password',
  '/auth/reset-password/verify-otp',
  '/auth/reset-password',
  '/app-version',
  '/users/me',
  '/users/me/settings',
  '/users/me/export',
  '/tasks',
  '/tasks/{}',
  '/tasks/sync',
  '/journal',
  '/journal/{}',
  '/journal/sync',
  '/notifications/preferences',
  '/notifications/preferences/{}',
  '/notifications/delivery',
  '/notifications/{}/read',
  '/notifications/sync',
  '/notifications/devices/register',
  '/notifications/devices/unregister',
  '/quotes/daily',
  '/quotes/random',
  // Called from features/ai_assistant (not scanned here), listed to match
  // the server's contract_paths.txt.
  '/n8n-chat/{}',
};

/// Paths the app calls that the server doesn't serve *yet*, each a known,
/// tracked gap. Keep this list short; never add to it to make the test pass.
const knownMissing = <String>{};

/// Directories holding code that talks to the API. Router paths ('/home',
/// '/settings', …) live elsewhere and are not API calls.
const apiCodeDirs = ['lib/core/services', 'lib/core/api'];

/// `'/tasks/$taskId?x=1'` -> `/tasks/{}`
String normalize(String path) => path
    .split('?')
    .first
    .replaceAll(RegExp(r'\$\{[^}]+\}|\$[A-Za-z_]\w*'), '{}');

Map<String, Set<String>> pathsUsedByApp() {
  final literal = RegExp(r"'(/[a-z][^' ]*)'");
  final baseUrl = RegExp(r"(?:\$apiBaseUrl|\$\{AppConfig\.apiBaseUrl\})(/[^' ]*)'");
  final used = <String, Set<String>>{};
  for (final dir in apiCodeDirs) {
    for (final file in Directory(dir)
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final source = file.readAsStringSync();
      for (final m in [...literal.allMatches(source), ...baseUrl.allMatches(source)]) {
        used.putIfAbsent(normalize(m.group(1)!), () => {}).add(file.path);
      }
    }
  }
  return used;
}

void main() {
  test('normalize', () {
    expect(normalize(r'/tasks/$taskId'), '/tasks/{}');
    expect(normalize(r'/quotes/random?category=$category'), '/quotes/random');
    expect(normalize(r'/notifications/${n.id}/read'), '/notifications/{}/read');
  });

  test('every API path the app calls exists on the server', () {
    final used = pathsUsedByApp();
    expect(used, isNotEmpty, reason: 'scanner found nothing; check apiCodeDirs');

    final unknown = {
      for (final e in used.entries)
        if (!serverPaths.contains(e.key) && !knownMissing.contains(e.key))
          e.key: e.value,
    };
    expect(unknown, isEmpty,
        reason: 'Paths not served by the DayZen API (path -> files): $unknown');
  });

  test('known gaps are still real (remove them from knownMissing when fixed)',
      () {
    expect(serverPaths.intersection(knownMissing), isEmpty);
    expect(pathsUsedByApp().keys.toSet().containsAll(knownMissing), isTrue,
        reason: 'A known-missing path is no longer called; drop it from the list');
  });

  test('the scanner sees the auth URLs built from apiBaseUrl', () {
    expect(pathsUsedByApp().keys, containsAll(['/auth/login', '/auth/logout']));
  });
}
