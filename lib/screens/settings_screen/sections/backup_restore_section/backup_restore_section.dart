import 'dart:convert';
import 'dart:io';

import 'package:Rem/provider/archives_provider.dart';
import 'package:Rem/widgets/snack_bar/custom_snack_bar.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../provider/reminders_provider.dart';
import '../../../../utils/logger/global_logger.dart';

class BackupRestoreSection extends ConsumerWidget {
  const BackupRestoreSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.backup, color: Colors.transparent),
          title: Text(
            "Backup & Restore (Experimental)",
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        SizedBox(height: 5),
        Column(
          children: [
            getBackupTile(context, ref),
            getRestoreTile(context, ref),
          ],
        )
      ],
    );
  }

  Widget getBackupTile(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(Icons.backup_outlined),
      title: Text('Backup', style: Theme.of(context).textTheme.titleSmall),
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
          String remindersJsonData =
              await ref.read(remindersProvider).getBackup();
          String archivesJsonData =
              await ref.read(archivesProvider).getBackup();

          // Create a temporary zip file in memory
          final archive = Archive();
          archive.addFile(ArchiveFile('reminders_backup.json',
              remindersJsonData.length, utf8.encode(remindersJsonData)));
          archive.addFile(ArchiveFile('archives_backup.json',
              archivesJsonData.length, utf8.encode(archivesJsonData)));
          final List<int>? zipData = ZipEncoder().encode(archive);

          if (zipData == null || zipData.isEmpty) {
            gLogger.i('Failed to create zip data | Data : $zipData');
            return;
          }

          Directory dir = Directory('storage/emulated/0/Download');
          if (dir.existsSync() == false) {
            dir.createSync();
          }

          String outputPath = dir.path + '/reminders_backup.zip';

          final file = File(outputPath);
          await file.writeAsBytes(zipData);

          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(content: Text('Backup created: $outputPath')),
          );
        } catch (e, stackTrace) {
          gLogger.e('Error during backup', error: e, stackTrace: stackTrace);
          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(
                content: Text('Backup failed: ${e.toString()}')),
          );
        }
      },
    );
  }

  Widget getRestoreTile(BuildContext context, WidgetRef ref) {
    return ListTile(
        leading: Icon(Icons.settings_backup_restore),
        title: Text('Restore', style: Theme.of(context).textTheme.titleSmall),
        onTap: () async {
          var status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              buildCustomSnackBar(
                  content: Text('Storage permission is required for restore')),
            );
            return;
          }

          try {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['zip'],
            );

            if (result == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                buildCustomSnackBar(content: Text('No file selected')),
              );
              return;
            }

            File file = File(result.files.single.path!);
            List<int> bytes = await file.readAsBytes();

            final archive = ZipDecoder().decodeBytes(bytes);

            final remindersJsonFile = archive.findFile('reminders_backup.json');
            if (remindersJsonFile == null) {
              gLogger
                  .e("File 'reminders_backup.json' not found in the zip file");
            } else {
              final remindersJsonContent =
                  utf8.decode(remindersJsonFile.content);
              ref.read(remindersProvider).restoreBackup(remindersJsonContent);
            }

            final archivesJsonFile = archive.findFile('archives_backup.json');
            if (archivesJsonFile == null) {
              gLogger
                  .e("File 'archives_backup.json' not found in the zip file");
            } else {
              final archivesJsonContent = utf8.decode(archivesJsonFile.content);
              ref.read(archivesProvider).restoreBackup(archivesJsonContent);
            }

            ScaffoldMessenger.of(context).showSnackBar(
              buildCustomSnackBar(
                  content: Text('Backup restored successfully')),
            );
          } catch (e, stackTrace) {
            gLogger.e('Error during restore', error: e, stackTrace: stackTrace);
            ScaffoldMessenger.of(context).showSnackBar(
              buildCustomSnackBar(
                  content: Text('Restore failed: ${e.toString()}')),
            );
          }
        });
  }
}
