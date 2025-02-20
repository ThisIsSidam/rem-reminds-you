import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/enums/files_n_folders.dart';
import 'global_logger.dart';

class LogsManager {
  Future<String> get directoryPath async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/${FilesNFolders.logsFolder.name}';
  }

  Future<List<int>?> createLogsZipData(
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

  Future<void> clearLogs() async {
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
