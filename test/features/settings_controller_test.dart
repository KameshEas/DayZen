import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dayzen/core/domain/quiet_window.dart';

import 'package:dayzen/features/settings/settings_controller.dart';
import 'package:dayzen/core/design_system/tokens/dz_colors.dart';

void main() {
  late SettingsController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    controller = SettingsController();
  });

  tearDown(() async {
    controller.dispose();
  });

  group('SettingsController', () {
    test('initializes with defaults', () {
      expect(controller.themeMode, equals(ThemeMode.system));
      expect(controller.accent, equals('Brand Navy'));
      expect(controller.fontSize, equals('Standard (16px)'));
      expect(controller.remindersEnabled, true);
      expect(controller.quietWindow, isNull);
    });

    test('provides correct accent color for each option', () {
      controller.setAccent('Sunrise');
      expect(controller.accent, equals('Sunrise'));
      expect(controller.accentColor, equals(DzColors.sunrise));

      controller.setAccent('Sage');
      expect(controller.accent, equals('Sage'));

      controller.setAccent('Lavender');
      expect(controller.accent, equals('Lavender'));

      controller.setAccent('Brand Navy');
      expect(controller.accent, equals('Brand Navy'));
      expect(controller.accentColor, equals(DzColors.navy));
    });

    test('toggles task reminders', () {
      controller.setRemindersEnabled(false);
      expect(controller.remindersEnabled, false);
      controller.setRemindersEnabled(true);
      expect(controller.remindersEnabled, true);
    });

    test('sets and clears quiet hours', () {
      controller.setQuietWindow(QuietWindow.defaultWindow);
      expect(controller.quietWindow, QuietWindow.defaultWindow);
      controller.setQuietWindow(null);
      expect(controller.quietWindow, isNull);
    });

    test('reminders and quiet hours survive a restart', () async {
      controller
        ..setRemindersEnabled(false)
        ..setQuietWindow(const QuietWindow(startMinutes: 23 * 60, endMinutes: 6 * 60 + 30));
      await Future<void>.delayed(Duration.zero); // let _save finish

      final reloaded = SettingsController();
      await reloaded.load();
      expect(reloaded.remindersEnabled, false);
      expect(reloaded.quietWindow,
          const QuietWindow(startMinutes: 23 * 60, endMinutes: 6 * 60 + 30));
      reloaded.dispose();
    });

    group('upgrade from the old two-flag settings (P1-10)', () {
      Future<SettingsController> loadWith(Map<String, Object> prefs) async {
        SharedPreferences.setMockInitialValues(prefs);
        final c = SettingsController();
        await c.load();
        return c;
      }

      test('reminders stay on if either old flag was on', () async {
        final c = await loadWith({'s_quietHours': true, 's_focusAlerts': false});
        expect(c.remindersEnabled, true);
        c.dispose();
      });

      test('reminders stay off if both old flags were off', () async {
        final c = await loadWith({'s_quietHours': false, 's_focusAlerts': false});
        expect(c.remindersEnabled, false);
        c.dispose();
      });

      test('quiet hours start off: the old flag never silenced anything',
          () async {
        final c = await loadWith({'s_quietHours': true, 's_focusAlerts': true});
        expect(c.quietWindow, isNull);
        c.dispose();
      });
    });

    test('changes theme mode', () {
      controller.setThemeMode(ThemeMode.light);
      expect(controller.themeMode, equals(ThemeMode.light));

      controller.setThemeMode(ThemeMode.dark);
      expect(controller.themeMode, equals(ThemeMode.dark));

      controller.setThemeMode(ThemeMode.system);
      expect(controller.themeMode, equals(ThemeMode.system));
    });

    test('provides theme mode label', () {
      controller.setThemeMode(ThemeMode.light);
      expect(controller.themeModeLabel, contains('Light'));

      controller.setThemeMode(ThemeMode.dark);
      expect(controller.themeModeLabel, contains('Dark'));

      controller.setThemeMode(ThemeMode.system);
      expect(controller.themeModeLabel, contains('System'));
    });

    test('changes font size', () {
      controller.setFontSize('Large (18px)');
      expect(controller.fontSize, equals('Large (18px)'));

      controller.setFontSize('Small (14px)');
      expect(controller.fontSize, equals('Small (14px)'));

      controller.setFontSize('Standard (16px)');
      expect(controller.fontSize, equals('Standard (16px)'));
    });

    test('notifies listeners on settings change', () {
      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.setRemindersEnabled(false);
      expect(notifyCount, greaterThan(0));
    });

    test('all accent options are valid', () {
      for (final accent in SettingsController.accentOptions) {
        expect(SettingsController.accentColorMap.containsKey(accent), true);
      }
    });

    test('all font size options are valid', () {
      expect(SettingsController.fontSizeOptions, isNotEmpty);
      for (final size in SettingsController.fontSizeOptions) {
        expect(size, isNotEmpty);
      }
    });
  });
}
