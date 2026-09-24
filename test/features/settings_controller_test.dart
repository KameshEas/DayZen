import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dayzen/features/settings/settings_controller.dart';
import 'package:dayzen/core/design_system/tokens/dz_colors.dart';

void main() {
  late SettingsController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
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
      expect(controller.quietHours, true);
      expect(controller.focusAlerts, true);
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

    test('toggles quiet hours', () {
      expect(controller.quietHours, true);
      controller.setQuietHours(false);
      expect(controller.quietHours, false);
      controller.setQuietHours(true);
      expect(controller.quietHours, true);
    });

    test('toggles focus alerts', () {
      expect(controller.focusAlerts, true);
      controller.setFocusAlerts(false);
      expect(controller.focusAlerts, false);
      controller.setFocusAlerts(true);
      expect(controller.focusAlerts, true);
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

      controller.setQuietHours(false);
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
