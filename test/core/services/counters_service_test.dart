import 'dart:convert';
import 'dart:io';

import 'package:dayzen/core/data/database/app_database.dart';
import 'package:dayzen/core/data/database/database_provider.dart';
import 'package:dayzen/core/routing/route_paths.dart';
import 'package:dayzen/core/services/counters_service.dart';
import 'package:dayzen/features/settings/widgets/settings_privacy_banner.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final counters = CountersService.instance;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DatabaseProvider.instanceForTesting =
        AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await DatabaseProvider.instance.close();
    DatabaseProvider.resetForTesting();
  });

  test('increments and snapshots every known counter', () async {
    await counters.increment(CountersService.daysClosed);
    await counters.increment(CountersService.daysClosed);
    await counters.increment(CountersService.checkinPrompts, by: 2);
    final snap = await counters.snapshot();
    expect(snap.keys, CountersService.all);
    expect(snap[CountersService.daysClosed], 2);
    expect(snap[CountersService.checkinPrompts], 2);
    expect(snap[CountersService.onboardingStarted], 0);
  });

  test('time-to-first-plan keeps the newest samples and a median', () async {
    for (var i = 1; i <= CountersService.maxTtfpSamples + 5; i++) {
      await counters.addTtfpSample(Duration(seconds: i));
    }
    final samples = await counters.ttfpSamples();
    expect(samples, hasLength(CountersService.maxTtfpSamples));
    expect(samples.first, 6000, reason: 'oldest dropped first');
    expect(CountersService.median([3, 1, 2]), 2);
    expect(CountersService.median([1, 2, 3, 4]), 3);
    expect(CountersService.median([]), isNull);
  });

  test('the feedback export holds counts only', () async {
    await counters.increment(CountersService.onboardingCompleted);
    await counters.addTtfpSample(const Duration(seconds: 40));
    final json = jsonDecode(await counters.exportJson()) as Map<String, dynamic>;
    expect(json.keys, containsAll(['counters', 'ttfp_ms', 'exported_at']));
    expect((json['counters'] as Map)[CountersService.onboardingCompleted], 1);
    expect((json['ttfp_ms'] as Map)['median'], 40000);
  });

  testWidgets('seven taps on the app version open the hidden counters',
      (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'DayZen',
      packageName: 'x',
      version: '1.2.3',
      buildNumber: '1',
      buildSignature: '',
    );
    var opened = false;
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: SettingsPrivacyBanner()),
      ),
      GoRoute(
        path: RoutePaths.counters,
        builder: (_, _) {
          opened = true;
          return const Scaffold(body: Text('counters'));
        },
      ),
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    final version = find.text('App Version 1.2.3');
    for (var i = 0; i < SettingsPrivacyBanner.secretTaps - 1; i++) {
      await tester.tap(version);
      await tester.pump();
    }
    expect(opened, isFalse);
    await tester.tap(version);
    await tester.pumpAndSettle();
    expect(opened, isTrue);
  });

  test('no network: the service imports no HTTP or API client', () {
    // Guards against an "upload counters" change slipping in without a
    // consent screen and an endpoint (plan §10).
    final src = File('lib/core/services/counters_service.dart').readAsStringSync();
    expect(src, isNot(contains('package:http')));
    expect(src, isNot(contains('api_client')));
  });
}
