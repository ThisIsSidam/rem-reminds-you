import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/extensions/context_ext.dart';
import '../../../../../core/services/notification_service/notification_service.dart';
import '../../../../../shared/utils/logger/app_logger.dart';
import '../../../../../shared/utils/misc_methods.dart';
import '../../../../../shared/widgets/snack_bar/custom_snack_bar.dart';
import '../../../../agenda/presentation/providers/agenda_provider.dart';
import '../../../../reminder/presentation/providers/no_rush_provider.dart';
import '../../../../reminder/presentation/providers/reminders_provider.dart';
import '../../providers/settings_provider.dart';
import '../shared/standard_setting_tile.dart';

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
            AppUtils.showToast(
              msg: context.local.settingsNoDirectorySelected,
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
          if (!context.mounted) return;
          AppUtils.showToast(
            msg: context.local.settingsBackupCreated,
            type: ToastificationType.success,
          );
        } catch (e, stackTrace) {
          AppLogger.e('Error during backup', error: e, stackTrace: stackTrace);
          AppUtils.showToast(
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
            AppUtils.showToast(
              msg: context.local.settingsNoFileSelected,
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

          // Use agenda backup part if available
          await _loadAgendaFromBackup(ref, archive);

          // Use settings backup part if available
          await _loadSettingsFromBackup(ref, archive);

          if (!context.mounted) return;
          AppUtils.showToast(
            msg: context.local.settingsBackupRestored,
            type: ToastificationType.success,
          );
        } catch (e, stackTrace) {
          AppLogger.e('Error during restore', error: e, stackTrace: stackTrace);
          if (!context.mounted) return;
          AppUtils.showToast(
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

  Future<void> _loadRemindersFromBackup(WidgetRef ref, Archive archive) async {
    try {
      final ArchiveFile? remindersJsonFile = archive.findFile(
        'reminders_backup.json',
      );

      if (remindersJsonFile == null) {
        AppLogger.e("File 'reminders_backup.json' not found in the zip file");
      } else {
        final String remindersJsonContent = utf8.decode(
          remindersJsonFile.content as List<int>,
        );
        await ref
            .read(remindersProvider.notifier)
            .restoreBackup(remindersJsonContent);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to restore Reminders',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _loadNoRushFromBackup(WidgetRef ref, Archive archive) async {
    try {
      final ArchiveFile? archivesJsonFile = archive.findFile(
        'no_rush_backup.json',
      );

      if (archivesJsonFile == null) {
        AppLogger.e(
          "File 'no_rush_reminders_backup.json' not found in the zip file",
        );
      } else {
        final String archivesJsonContent = utf8.decode(
          archivesJsonFile.content as List<int>,
        );
        await ref
            .read(noRushRemindersProvider.notifier)
            .restoreBackup(archivesJsonContent);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to restore No Rush Reminders',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _loadAgendaFromBackup(WidgetRef ref, Archive archive) async {
    try {
      final ArchiveFile? agendaJsonFile = archive.findFile(
        'agenda_backup.json',
      );

      if (agendaJsonFile == null) {
        AppLogger.e("File 'agenda_backup.json' not found in the zip file");
      } else {
        final String agendaJsonContent = utf8.decode(
          agendaJsonFile.content as List<int>,
        );
        ref.read(agendaProvider.notifier).restoreBackup(agendaJsonContent);
        final agendaTime = ref.read(userSettingsProvider).defaultAgendaTime;
        final agendaDateTime = MiscMethods.getAgendaDateTime(agendaTime);
        await NotificationService.scheduleAgenda(agendaDateTime);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to restore Agenda Tasks',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _loadSettingsFromBackup(WidgetRef ref, Archive archive) async {
    try {
      final ArchiveFile? settingsJsonFile = archive.findFile(
        'settings_backup.json',
      );

      if (settingsJsonFile == null) {
        AppLogger.e("File 'settings_backup.json' not found in the zip file");
      } else {
        final String settingsJsonContent = utf8.decode(
          settingsJsonFile.content as List<int>,
        );
        await ref.read(userSettingsProvider).restoreBackup(settingsJsonContent);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to restore User Settings',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
