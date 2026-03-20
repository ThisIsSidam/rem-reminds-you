import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        try {
          // Get backup data
          final Uint8List? backupData = await _getBackupData(ref);
          if (backupData == null || backupData.isEmpty) {
            gLogger.i('Failed to create zip data | Data : $backupData');
            return;
          }

          // Get save location directory
          final DirectoryLocation? saveLocation =
              await FlutterFileDialog.pickDirectory();

          // User cancelled operation
          if (saveLocation == null) {
            AppUtils.showToast(
              msg: 'No directory selected',
              type: ToastificationType.warning,
            );
            return;
          }

          // Save new backup file
          final int millis = DateTime.now().millisecondsSinceEpoch;
          final String fileName = 'rem-backup-$millis.zip';
          const String mimeType = 'application/zip';
          await FlutterFileDialog.saveFileToDirectory(
            directory: saveLocation,
            data: backupData,
            mimeType: mimeType,
            fileName: fileName,
            replace: true,
          );
          AppUtils.showToast(
            msg: 'Backup created successfully',
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
        try {
          // Get file path of selected file
          final String? filePath = await FlutterFileDialog.pickFile(
            params: const OpenFileDialogParams(
              fileExtensionsFilter: <String>['zip'],
            ),
          );

          // Check if user did select a file
          if (filePath == null) {
            if (!context.mounted) return;
            AppUtils.showToast(
              msg: 'No file selected',
              type: ToastificationType.warning,
            );
            return;
          }

          // Get file instance and restore backup
          final File file = File(filePath);
          final List<int> bytes = await file.readAsBytes();

          final Archive archive = ZipDecoder().decodeBytes(bytes);

          // Use Reminders backup part if available
          await _loadRemindersFromBackup(ref, archive);

          // Use no rush reminders backup part if available
          await _loadNoRushFromBackup(ref, archive);

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

  // ----------------------------------
  // ----- Helpers --------------------------
  // ----------------------------------

  Future<Uint8List?> _getBackupData(WidgetRef ref) async {
    // Get backup string
    final String remindersJsonData =
        await ref.read(remindersNotifierProvider.notifier).getBackup();
    final String noRushJsonData =
        await ref.read(noRushRemindersNotifierProvider.notifier).getBackup();

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
          'no_rush_backup.json',
          noRushJsonData.length,
          utf8.encode(noRushJsonData),
        ),
      );
    final List<int>? zipData = ZipEncoder().encode(archive);
    if (zipData == null) return null;
    return Uint8List.fromList(zipData);
  }

  Future<void> _loadRemindersFromBackup(WidgetRef ref, Archive archive) async {
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
  }

  Future<void> _loadNoRushFromBackup(WidgetRef ref, Archive archive) async {
    final ArchiveFile? archivesJsonFile =
        archive.findFile('no_rush_backup.json');

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
  }
}
