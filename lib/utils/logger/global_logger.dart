import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class GLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );

  // Add Debug Log
  static void d(String msg, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _logger.d(msg, error: error, stackTrace: stackTrace);
    }
  }

  // Add Info Log
  static void i(String msg, {Object? error, StackTrace? stackTrace}) {
    _logger.d(msg, error: error, stackTrace: stackTrace);
  }

  // Add Warning Log
  static void w(String msg, {Object? error, StackTrace? stackTrace}) {
    _logger.d(msg, error: error, stackTrace: stackTrace);
  }

  // Add Error Log
  static void e(String msg, {Object? error, StackTrace? stackTrace}) {
    _logger.d(msg, error: error, stackTrace: stackTrace);
  }

  // Add log to log file
  static void _addLogToFile(String msg) {}
}
