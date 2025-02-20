import 'package:logger/logger.dart';

import 'file_output.dart';

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
  final AppFileOutput fileOutput = AppFileOutput();
  await fileOutput.init();

  if (isLoggerInitialized) return;
  gLogger = Logger(
    printer: HybridPrinter(
      LogfmtPrinter(),
      error: PrettyPrinter(
        lineLength: 30,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
      fatal: PrettyPrinter(
        errorMethodCount: 12,
        lineLength: 30,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
      warning: PrettyPrinter(
        errorMethodCount: 6,
        lineLength: 30,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
      info: SimplePrinter(),
      debug: SimplePrinter(),
    ),
    output: MultiOutput(
      <LogOutput>[ConsoleOutput(), fileOutput],
    ),
  );
}
