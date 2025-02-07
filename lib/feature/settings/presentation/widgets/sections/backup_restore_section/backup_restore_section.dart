import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../../shared/utils/logger/global_logger.dart';
import '../../../../../../shared/widgets/snack_bar/custom_snack_bar.dart';
import '../../../../../archives/presentation/providers/archives_provider.dart';
import '../../../../../home/presentation/providers/reminders_provider.dart';

class BackupRestoreSection extends ConsumerWidget {
  const BackupRestoreSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.backup, color: Colors.transparent),
          title: Text(
            'Backup & Restore (Experimental)',
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        const SizedBox(height: 5),
        Column(
          children: <Widget>[
            getBackupTile(context, ref),
            getRestoreTile(context, ref),
          ],
        ),
      ],
    );
  }

  Widget getBackupTile(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.backup_outlined),
      title: Text('Backup', style: Theme.of(context).textTheme.titleSmall),
      onTap: () async {
        final PermissionStatus status2 =
            await Permission.manageExternalStorage.request();
        if (!status2.isGranted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(
              content: const Text('Storage2 permission is required for backup'),
            ),
          );
          return;
        }

        try {
          final String remindersJsonData =
              await ref.read(remindersProvider).getBackup();
          final String archivesJsonData =
              await ref.read(archivesProvider).getBackup();

          // Create a temporary zip file in memory
          final Archive archive = Archive()
            ..addFile(
              ArchiveFile(
                'reminders_backup.json',
                remindersJsonData.length,
                utf8.encode(remindersJsonData),
              ),
            )
            ..addFile(
              ArchiveFile(
                'archives_backup.json',
                archivesJsonData.length,
                utf8.encode(archivesJsonData),
              ),
            );
          final List<int>? zipData = ZipEncoder().encode(archive);

          if (zipData == null || zipData.isEmpty) {
            gLogger.i('Failed to create zip data | Data : $zipData');
            return;
          }

          final Directory dir = Directory('storage/emulated/0/Download');
          if (dir.existsSync() == false) {
            dir.createSync();
          }

          final String outputPath = '${dir.path}/reminders_backup.zip';

          final File file = File(outputPath);
          await file.writeAsBytes(zipData);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(content: Text('Backup created: $outputPath')),
          );
        } catch (e, stackTrace) {
          gLogger.e('Error during backup', error: e, stackTrace: stackTrace);
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(
              content: Text('Backup failed: $e'),
            ),
          );
        }
      },
    );
  }

  Widget getRestoreTile(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.settings_backup_restore),
      title: Text('Restore', style: Theme.of(context).textTheme.titleSmall),
      onTap: () async {
        final PermissionStatus status =
            await Permission.manageExternalStorage.request();
        if (!status.isGranted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(
              content: const Text('Storage permission is required for restore'),
            ),
          );
          return;
        }

        try {
          final FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: <String>['zip'],
          );

          if (result == null) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              buildCustomSnackBar(content: const Text('No file selected')),
            );
            return;
          }

          final File file = File(result.files.single.path!);
          final List<int> bytes = await file.readAsBytes();

          final Archive archive = ZipDecoder().decodeBytes(bytes);

          final ArchiveFile? remindersJsonFile =
              archive.findFile('reminders_backup.json');
          if (remindersJsonFile == null) {
            gLogger.e("File 'reminders_backup.json' not found in the zip file");
          } else if (remindersJsonFile.content is List<int>) {
            final String remindersJsonContent =
                utf8.decode(remindersJsonFile.content as List<int>);
            await ref.read(remindersProvider).restoreBackup(
                  remindersJsonContent,
                );
          } else {
            gLogger.e('File contents not found');
          }

          final ArchiveFile? archivesJsonFile =
              archive.findFile('archives_backup.json');
          if (archivesJsonFile == null) {
            gLogger.e("File 'archives_backup.json' not found in the zip file");
          } else if (archivesJsonFile.content is List<int>) {
            final String archivesJsonContent =
                utf8.decode(archivesJsonFile.content as List<int>);
            await ref.read(archivesProvider).restoreBackup(archivesJsonContent);
          } else {
            gLogger.e('File contents not found');
          }

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(
              content: const Text('Backup restored successfully'),
            ),
          );
        } catch (e, stackTrace) {
          gLogger.e('Error during restore', error: e, stackTrace: stackTrace);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(
              content: Text('Restore failed: $e'),
            ),
          );
        }
      },
    );
  }
}
