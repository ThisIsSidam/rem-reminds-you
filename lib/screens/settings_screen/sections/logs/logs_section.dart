import 'dart:io';

import 'package:Rem/consts/enums/files_n_folders.dart';
import 'package:Rem/widgets/snack_bar/custom_snack_bar.dart';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../utils/logger/global_logger.dart';

class LogsSection extends ConsumerWidget {
  const LogsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.backup, color: Colors.transparent),
          title: Text(
            "Logs",
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        SizedBox(height: 5),
        Column(
          children: [
            getLogsTile(context, ref),
          ],
        )
      ],
    );
  }

  Widget getLogsTile(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(Icons.storage),
      title:
          Text('Get log file', style: Theme.of(context).textTheme.titleSmall),
      onTap: () async {
        var status2 = await Permission.manageExternalStorage.request();
        if (!status2.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(
                content: Text('Storage2 permission is required for backup')),
          );
          return;
        }

        try {
          final Directory storage = await getApplicationDocumentsDirectory();
          final Directory srcFolder =
              Directory('${storage.path}/${FilesNFolders.logsFolder.name}');

          Directory extStorage = Directory('storage/emulated/0/Download');
          if (extStorage.existsSync() == false) {
            extStorage.createSync();
          }

          final outputFile = File('${extStorage.path}/rem_logs.zip');
          final List<int>? zipData =
              await createLogsZipData(srcFolder, outputFile);

          if (zipData != null) {
            await outputFile.writeAsBytes(zipData);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(
                content: Text('Logs saved : ${outputFile.path}')),
          );
        } catch (e, stackTrace) {
          gLogger.e('Error during exporting logs',
              error: e, stackTrace: stackTrace);
          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(
                content: Text('Backup failed: ${e.toString()}')),
          );
        }
      },
    );
  }

  Future<List<int>?> createLogsZipData(
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
}
