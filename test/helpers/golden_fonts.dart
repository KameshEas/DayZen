import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the app's real fonts (Inter, Bodoni Moda, Material Icons, ...) so
/// golden images show actual text instead of the test font's blocks. Call
/// once in a golden test's setUpAll.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List<dynamic>;
  for (final family in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(family['family'] as String);
    for (final font in (family['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}
