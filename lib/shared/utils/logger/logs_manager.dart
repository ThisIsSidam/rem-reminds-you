import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../app/enums/files_n_folders.dart';
import 'app_logger.dart';

class LogsManager {
  Future<String> get directoryPath async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/${FilesNFolders.logsFolder.name}';
  }

  Future<List<int>> createLogsZipData() async {
    // Forces a IOSink Flush in logger since 'w' is one
    // of the logs that gets flushed immediately.
    AppLogger.w('Flushing logs before export');
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final Directory srcDirectory = Directory(await directoryPath);

    final ZipEncoder encoder = ZipEncoder();
    final Archive archive = Archive();

    // Get all files in the source directoryz
    final List<FileSystemEntity> entities = await srcDirectory
        .list(recursive: true)
        .toList();

    // Add each file to the archive
    for (final FileSystemEntity entity in entities) {
      if (entity is File) {
        final String relativePath = p.relative(
          entity.path,
          from: srcDirectory.path,
        );
        final Uint8List data = await entity.readAsBytes();
        final ArchiveFile archiveFile = ArchiveFile(
          'rem-logs/$relativePath',
          data.length,
          data,
        );
        archive.addFile(archiveFile);
      }
    }

    return encoder.encode(archive);
  }

  Future<void> clearLogs() async {
    final Directory logsDirectory = Directory(await directoryPath);

    if (!logsDirectory.existsSync()) {
      AppLogger.i('Attempted to delete logs | Folder does not exist');
      return;
    }

    await for (final FileSystemEntity entity in logsDirectory.list()) {
      try {
        await entity.delete(recursive: true);
      } catch (e) {
        AppLogger.e('Error deleting log files');
      }
    }
  }
}
