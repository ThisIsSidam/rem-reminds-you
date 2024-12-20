import 'dart:io';

import 'package:archive/archive.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mutex/mutex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/enums/files_n_folders.dart';
import 'global_logger.dart';

class AppFileOutput extends LogOutput {
  Directory? logs_directory;
  final mutex = Mutex();

  Future<void> init() async {
    logs_directory = Directory(await LogsManager.directoryPath);

    if (!await logs_directory!.exists()) {
      await logs_directory!.create();
    }
  }

  static String getDateAsString() {
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

    if (!await file.exists()) {
      await file.create();
    }

    // Use a mutex to ensure writes do not overlap
    await mutex.protect(
      () async {
        for (var line in event.lines) {
          final String formattedDateTime =
              DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
          await file.writeAsString('$formattedDateTime  $line\n',
              mode: FileMode.append);
        }
      },
    );
  }
}

class LogsManager {
  static Future<String> get directoryPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/${FilesNFolders.logsFolder.name}';
  }

  static Future<List<int>?> createLogsZipData(
      Directory srcFolder, File outputFile) async {
    final encoder = ZipEncoder();
    final archive = Archive();

    // Get all files in the source directory
    final entities = await srcFolder.list(recursive: true).toList();

    // Add each file to the archive
    for (var entity in entities) {
      if (entity is File) {
        final relativePath = p.relative(entity.path, from: srcFolder.path);
        final data = await entity.readAsBytes();
        final archiveFile = ArchiveFile(
          relativePath,
          data.length,
          data,
        );
        archive.addFile(archiveFile);
      }
    }

    final List<int>? zipData = encoder.encode(archive);
    return zipData;
  }

  static Future<void> clearLogs() async {
    Directory logs_directory = Directory(await directoryPath);

    if (!await logs_directory.exists()) {
      gLogger.i('Attempted to delete logs | Folder does not exist');
      return;
    }

    await for (final FileSystemEntity entity in logs_directory.list()) {
      try {
        entity.delete(recursive: true);
      } catch (e) {
        gLogger.e('Error deleting log files');
      }
    }
  }
}
