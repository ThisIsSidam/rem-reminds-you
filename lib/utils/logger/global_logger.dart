import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// Global instance of [Logger].
/// Needs to be called [initLogger] for it to work.
late final Logger gLogger;

bool get isLoggerInitialized {
  try {
    return gLogger != null;
  } catch (e) {
    return false;
  }
}

Future<void> initLogger() async {
  final FileOutput fileOutput = FileOutput();
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

class FileOutput extends LogOutput {
  final String fileName;
  File? _file;

  FileOutput({this.fileName = 'app_logs.txt'});

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    _file = File('${directory.path}/$fileName');

    // Create file if it doesn't exist
    if (!await _file!.exists()) {
      await _file!.create();
    }
  }

  @override
  void output(OutputEvent event) async {
    if (_file == null) {
      await init();
    }

    // Write logs to file
    for (var line in event.lines) {
      await _file!.writeAsString('$line\n', mode: FileMode.append);
    }
  }
}
