import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/extensions/context_ext.dart';
import '../../../../../shared/utils/app_utils.dart';
import '../../../../../shared/utils/logger/app_logger.dart';
import '../../../../agenda/presentation/providers/agenda_provider.dart';
import '../../../../reminder/presentation/providers/no_rush_provider.dart';
import '../../../../reminder/presentation/providers/reminders_provider.dart';
import '../../providers/settings_provider.dart';
import '../shared/standard_setting_tile.dart';
import 'restore_progress_dialog.dart';

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
            context.local.settingsBackupRestore,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
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
    return StandardSettingTile(
      leading: Icons.backup_outlined,
      title: context.local.settingsBackup,
      onTap: () async {
        try {
          // Get backup data
          final Uint8List? backupData = await _getBackupData(ref);
          if (backupData == null || backupData.isEmpty) {
            AppLogger.i('Failed to create zip data | Data : $backupData');
            return;
          }

          // Get save location directory
          final DirectoryLocation? saveLocation =
              await FlutterFileDialog.pickDirectory();

          // User cancelled operation
          if (saveLocation == null) {
            if (!context.mounted) return;
            return showToast(
              context,
              msg: context.local.settingsNoDirectorySelected,
              type: ToastificationType.warning,
            );
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
          if (!context.mounted) return;
          showToast(
            context,
            msg: context.local.settingsBackupCreated,
            type: ToastificationType.success,
          );
        } catch (e, stackTrace) {
          AppLogger.e('Error during backup', error: e, stackTrace: stackTrace);
          showToast(
            context,
            msg: context.local.settingsBackupFailed,
            type: ToastificationType.error,
          );
        }
      },
    );
  }

  Widget getRestoreTile(BuildContext context, WidgetRef ref) {
    return StandardSettingTile(
      leading: Icons.settings_backup_restore,
      title: context.local.settingsRestore,
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
            return showToast(
              context,
              msg: context.local.settingsNoFileSelected,
              type: ToastificationType.warning,
            );
          }

          // Get file instance and restore backup
          final File file = File(filePath);
          final List<int> bytes = await file.readAsBytes();

          final Archive archive = ZipDecoder().decodeBytes(bytes);

          if (!context.mounted) return;

          // Show restoration progress dialog
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => RestoreProgressDialog(archive: archive),
          );
        } catch (e, stackTrace) {
          AppLogger.e('Error during restore', error: e, stackTrace: stackTrace);
          if (!context.mounted) return;
          showToast(
            context,
            msg: context.local.settingsRestoreFailed,
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
    final String remindersJsonData = await ref
        .read(remindersProvider.notifier)
        .getBackup();
    final String noRushJsonData = await ref
        .read(noRushRemindersProvider.notifier)
        .getBackup();
    final String agendaJsonData = ref.read(agendaProvider.notifier).getBackup();
    final String settingsJsonData = ref.read(userSettingsProvider).getBackup();

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
      )
      ..addFile(
        ArchiveFile(
          'agenda_backup.json',
          agendaJsonData.length,
          utf8.encode(agendaJsonData),
        ),
      )
      ..addFile(
        ArchiveFile(
          'settings_backup.json',
          settingsJsonData.length,
          utf8.encode(settingsJsonData),
        ),
      );
    final List<int> zipData = ZipEncoder().encode(archive);
    return Uint8List.fromList(zipData);
  }
}
