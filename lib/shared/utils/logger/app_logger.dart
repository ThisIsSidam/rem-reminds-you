import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'logs_manager.dart';

class AppLogger {
  AppLogger._(); // no instances

  static late Logger _logger;
  static bool _initialized = false;

  /// Initialize once
  static Future<void> init({String? directory}) async {
    if (_initialized) return;

    final String dirPath = directory ?? await LogsManager().directoryPath;

    final Directory dir = Directory(dirPath);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    final AdvancedFileOutput fileOutput = AdvancedFileOutput(
      path: dirPath,
      fileNameFormatter: (DateTime timestamp) =>
          'log_${timestamp.millisecondsSinceEpoch}.log',
    );

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        excludeBox: <Level, bool>{
          Level.info: true,
          Level.debug: true,
          Level.trace: true,
        },
      ),
      output: MultiOutput(<LogOutput?>[
        if (kDebugMode) ConsoleOutput(),
        fileOutput,
      ]),
    );

    _initialized = true;

    _logger.i('Logger initialized at $directory');
  }

  // --------------------
  // Static logging APIs
  // --------------------

  static void d(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (!_initialized) return;
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (!_initialized) return;
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (!_initialized) return;
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (!_initialized) return;
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void t(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (!_initialized) return;
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  static void f(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (!_initialized) return;
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
