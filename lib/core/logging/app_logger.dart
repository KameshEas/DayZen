import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Application logger wrapper around the logger package.
/// Suppresses debug/info in release mode; warnings/errors always captured.
class AppLogger {
  static final _logger = Logger(
    level: kReleaseMode ? Level.warning : Level.debug,
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 100,
      colors: !kReleaseMode,
      printEmojis: true,
    ),
  );

  /// Log a debug message (suppressed in release mode).
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!kReleaseMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log an info message (suppressed in release mode).
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!kReleaseMode) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log a warning message (always captured).
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log an error message (always captured).
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
