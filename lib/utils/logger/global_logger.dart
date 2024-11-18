import 'dart:io';

import 'package:Rem/consts/enums/files_n_folders.dart';
import 'package:intl/intl.dart';
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
  Directory? logs_directory;

  FileOutput();

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    logs_directory =
        Directory('${directory.path}/${FilesNFolders.logsFolder.name}');

    // Create folder if it doesn't exist
    if (!await logs_directory!.exists()) {
      await logs_directory!.create();
    }
  }

  String getDateAsString() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

  @override
  void output(OutputEvent event) async {
    if (logs_directory == null) {
      await init();
    }

    final File file = File(
        '${logs_directory?.path}/${FilesNFolders.logFilePrefix.name}${getDateAsString()}.txt');

    // Create file if it doesn't exist
    if (!await file.exists()) {
      await file.create();
    }

    // Write logs to file
    for (var line in event.lines) {
      final String formattedDateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
      await file.writeAsString('$formattedDateTime   $line\n',
          mode: FileMode.append);
    }
  }
}
