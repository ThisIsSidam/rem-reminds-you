import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';

import '../../../../../../shared/utils/logger/global_logger.dart';
import '../../../../../../shared/widgets/snack_bar/custom_snack_bar.dart';
import '../../../../../home/presentation/providers/no_rush_provider.dart';
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
          AppUtils.showToast(
            msg: 'Storage permission is required for backup',
            type: ToastificationType.warning,
          );
          return;
        }

        try {
          final String remindersJsonData =
              await ref.read(remindersNotifierProvider.notifier).getBackup();
          final String noRushJsonData = await ref
              .read(noRushRemindersNotifierProvider.notifier)
              .getBackup();

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
                noRushJsonData.length,
                utf8.encode(noRushJsonData),
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
          AppUtils.showToast(
            msg: 'Backup created',
            description: outputPath,
            type: ToastificationType.success,
          );
        } catch (e, stackTrace) {
          gLogger.e('Error during backup', error: e, stackTrace: stackTrace);
          AppUtils.showToast(
            msg: 'Backup failed!',
            type: ToastificationType.error,
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
          AppUtils.showToast(
            msg: 'Storage permission is required for restore',
            type: ToastificationType.warning,
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
            AppUtils.showToast(
              msg: 'No file selected',
              type: ToastificationType.warning,
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
            await ref.read(remindersNotifierProvider.notifier).restoreBackup(
                  remindersJsonContent,
                );
          } else {
            gLogger.e('File contents not found');
          }

          final ArchiveFile? archivesJsonFile =
              archive.findFile('no_rush_reminders_backup.json');
          if (archivesJsonFile == null) {
            gLogger.e(
              "File 'no_rush_reminders_backup.json' not found in the zip file",
            );
          } else if (archivesJsonFile.content is List<int>) {
            final String archivesJsonContent =
                utf8.decode(archivesJsonFile.content as List<int>);
            await ref
                .read(noRushRemindersNotifierProvider.notifier)
                .restoreBackup(archivesJsonContent);
          } else {
            gLogger.e('File contents not found');
          }

          AppUtils.showToast(
            msg: 'Backup restored successfully',
            type: ToastificationType.success,
          );
        } catch (e, stackTrace) {
          gLogger.e('Error during restore', error: e, stackTrace: stackTrace);
          if (!context.mounted) return;
          AppUtils.showToast(
            msg: 'Backup restore failed!',
            type: ToastificationType.error,
          );
        }
      },
    );
  }
}
