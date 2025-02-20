import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';

import '../../../../../../core/enums/files_n_folders.dart';
import '../../../../../../shared/utils/logger/global_logger.dart';
import '../../../../../../shared/utils/logger/logs_manager.dart';
import '../../../../../../shared/widgets/snack_bar/custom_snack_bar.dart';

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
            'Logs',
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.primary),
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
    return ListTile(
      leading: const Icon(Icons.storage),
      title:
          Text('Get log file', style: Theme.of(context).textTheme.titleSmall),
      onTap: () async {
        final PermissionStatus status2 =
            await Permission.manageExternalStorage.request();
        if (!status2.isGranted) {
          if (!context.mounted) return;
          AppUtils.showToast(
            msg: 'Storage permission is required for backup',
            type: ToastificationType.warning,
          );
          return;
        }

        try {
          final Directory storage = await getApplicationDocumentsDirectory();
          final Directory srcFolder = Directory(
            path.join(storage.path, FilesNFolders.logsFolder.name),
          );

          final Directory extStorage = Directory('storage/emulated/0/Download');
          if (extStorage.existsSync() == false) {
            extStorage.createSync();
          }

          final File outputFile = File(
            path.join(
              extStorage.path,
              '${FilesNFolders.logsFolder.name}.zip',
            ),
          );
          final List<int>? zipData =
              await LogsManager().createLogsZipData(srcFolder, outputFile);

          if (zipData != null) {
            await outputFile.writeAsBytes(zipData);
          }

          if (!context.mounted) return;
          AppUtils.showToast(
            msg: 'Logs saved',
            description: outputFile.path,
            type: ToastificationType.success,
          );
        } catch (e, stackTrace) {
          gLogger.e(
            'Error exporting logs',
            error: e,
            stackTrace: stackTrace,
          );
          if (!context.mounted) return;
          AppUtils.showToast(msg: "Couldn't export logs!");
        }
      },
    );
  }

  Widget getClearLogsTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder_delete),
      title: Text(
        'Clear all logs',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      onTap: () async {
        await LogsManager().clearLogs();
        AppUtils.showToast(msg: 'Successfully deleted all logs');
      },
    );
  }
}
