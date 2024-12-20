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
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 30,
        colors: true,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
      fatal: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 12,
        lineLength: 30,
        colors: true,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
      warning: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 6,
        lineLength: 30,
        colors: true,
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
