import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import '../../../../../../core/extensions/context_ext.dart';
import '../../../../../../shared/utils/logger/app_logger.dart';
import '../../../../../../shared/utils/logger/logs_manager.dart';
import '../../../../../../shared/widgets/snack_bar/custom_snack_bar.dart';
import '../../shared/standard_setting_tile.dart';

class LogsSection extends ConsumerWidget {
  const LogsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.backup, color: Colors.transparent),
          title: Text(
            context.local.settingsLogs,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Column(
          children: <Widget>[
            getLogsTile(context, ref),
            getClearLogsTile(context),
          ],
        ),
      ],
    );
  }

  Widget getLogsTile(BuildContext context, WidgetRef ref) {
    return StandardSettingTile(
      leading: Icons.storage,
      title: context.local.settingsGetLogFile,
      onTap: () async {
        try {
          final Uint8List? logsData = await _getLogsData();
          if (logsData == null || logsData.isEmpty) {
            AppLogger.e('Failed to find any relevant logs');
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
          final String fileName = 'rem-logs-$millis.zip';
          const String mimeType = 'application/zip';
          await FlutterFileDialog.saveFileToDirectory(
            directory: saveLocation,
            data: logsData,
            mimeType: mimeType,
            fileName: fileName,
            replace: true,
          );

          if (!context.mounted) return;
          AppUtils.showToast(
            msg: context.local.settingsLogsSaved,
            type: ToastificationType.success,
          );
        } catch (e, stackTrace) {
          AppLogger.e('Error exporting logs', error: e, stackTrace: stackTrace);
          if (!context.mounted) return;
          AppUtils.showToast(msg: context.local.settingsExportLogsFailed);
        }
      },
    );
  }

  Widget getClearLogsTile(BuildContext context) {
    return StandardSettingTile(
      leading: Icons.folder_delete,
      title: 'Clear all logs',
      onTap: () async {
        await LogsManager().clearLogs();
        AppUtils.showToast(msg: 'Successfully deleted all logs');
      },
    );
  }

  Future<Uint8List?> _getLogsData() async {
    final List<int>? zipData = await LogsManager().createLogsZipData();
    if (zipData == null) return null;
    return Uint8List.fromList(zipData);
  }
}
