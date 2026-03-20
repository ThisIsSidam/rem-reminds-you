import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../../core/enums/files_n_folders.dart';

/// Global instance of [Logger].
late final Logger gLogger;

/// Initialize the global instance of [Logger] -> [gLogger].
void initLogger({required String directory}) {
  try {
    final AdvancedFileOutput fileOutput = AdvancedFileOutput(
      path: directory,
      fileNameFormatter: (DateTime timestamp) =>
          // ignore: lines_longer_than_80_chars
          '${FilesNFolders.logFilePrefix}${timestamp.millisecondsSinceEpoch}.log',
    );

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
          if (kDebugMode) ConsoleOutput(),
          fileOutput,
        ],
      ),
    );
  } catch (e) {
    if (e is Error && e.toString().contains('LateInitializationError')) {
      gLogger
          .w('gLogger initialization cancelled | Logger already initialized');
    } else {
      rethrow;
    }
  }
}
