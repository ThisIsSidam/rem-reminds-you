import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mutex/mutex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/enums/files_n_folders.dart';
import 'global_logger.dart';

class AppFileOutput extends LogOutput {
  Directory? logsDirectory;
  final Mutex mutex = Mutex();

  @override
  Future<void> init() async {
    logsDirectory = Directory(await LogsManager.directoryPath);

    if (!logsDirectory!.existsSync()) {
      await logsDirectory!.create();
    }
  }

  static String getDateAsString() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

  @override
  Future<void> output(OutputEvent event) async {
    if (logsDirectory == null) {
      await init();
    }

    final File file = File(
      '${logsDirectory?.path}/${FilesNFolders.logFilePrefix.name}${getDateAsString()}.txt',
    );

    if (!file.existsSync()) {
      await file.create();
    }

    // Use a mutex to ensure writes do not overlap
    await mutex.protect(
      () async {
        for (final String line in event.lines) {
          final String formattedDateTime =
              DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
          await file.writeAsString(
            '$formattedDateTime  $line\n',
            mode: FileMode.append,
          );
        }
      },
    );
  }
}

class LogsManager {
  static Future<String> get directoryPath async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/${FilesNFolders.logsFolder.name}';
  }

  static Future<List<int>?> createLogsZipData(
    Directory srcFolder,
    File outputFile,
  ) async {
    final ZipEncoder encoder = ZipEncoder();
    final Archive archive = Archive();

    // Get all files in the source directory
    final List<FileSystemEntity> entities =
        await srcFolder.list(recursive: true).toList();

    // Add each file to the archive
    for (final FileSystemEntity entity in entities) {
      if (entity is File) {
        final String relativePath =
            p.relative(entity.path, from: srcFolder.path);
        final Uint8List data = await entity.readAsBytes();
        final ArchiveFile archiveFile = ArchiveFile(
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
    final Directory logsDirectory = Directory(await directoryPath);

    if (!logsDirectory.existsSync()) {
      gLogger.i('Attempted to delete logs | Folder does not exist');
      return;
    }

    await for (final FileSystemEntity entity in logsDirectory.list()) {
      try {
        await entity.delete(recursive: true);
      } catch (e) {
        gLogger.e('Error deleting log files');
      }
    }
  }
}
