import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../../core/enums/files_n_folders.dart';
import 'app_console_output.dart';
import 'logs_manager.dart';

/// Global instance of [Logger].
/// Needs to be called [initLogger] for it to work.
late final Logger gLogger;

bool get isLoggerInitialized {
  try {
    // ignore: unnecessary_null_comparison
    return gLogger != null;
  } catch (e) {
    return false;
  }
}

Future<void> initLogger() async {
  final AdvancedFileOutput fileOutput = AdvancedFileOutput(
    path: await LogsManager().directoryPath,
    fileNameFormatter: (DateTime timestamp) =>
        '${FilesNFolders.logFilePrefix}${timestamp.millisecondsSinceEpoch}.log',
  );

  if (isLoggerInitialized) return;
  gLogger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      dateTimeFormat:
          // ignore: avoid_redundant_argument_values
          kDebugMode ? DateTimeFormat.none : DateTimeFormat.dateAndTime,
      lineLength: 30,
      excludeBox: <Level, bool>{
        Level.info: true,
        Level.debug: true,
        Level.trace: true,
      },
    ),
    output: MultiOutput(
      <LogOutput>[
        if (kDebugMode) ConsoleOutput() else AppConsoleOutput(),
        fileOutput,
      ],
    ),
  );
}
