import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../../core/enums/files_n_folders.dart';
import '../../../../../../shared/utils/logger/file_output.dart';
import '../../../../../../shared/utils/logger/global_logger.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(
              content: const Text('Storage2 permission is required for backup'),
            ),
          );
          return;
        }

        try {
          final Directory storage = await getApplicationDocumentsDirectory();
          final Directory srcFolder =
              Directory('${storage.path}/${FilesNFolders.logsFolder.name}');

          final Directory extStorage = Directory('storage/emulated/0/Download');
          if (extStorage.existsSync() == false) {
            extStorage.createSync();
          }

          final File outputFile = File('${extStorage.path}/rem_logs.zip');
          final List<int>? zipData =
              await LogsManager.createLogsZipData(srcFolder, outputFile);

          if (zipData != null) {
            await outputFile.writeAsBytes(zipData);
          }

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(
              content: Text('Logs saved : ${outputFile.path}'),
            ),
          );
        } catch (e, stackTrace) {
          gLogger.e(
            'Error during exporting logs',
            error: e,
            stackTrace: stackTrace,
          );
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

  Widget getClearLogsTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder_delete),
      title: Text(
        'Clear all logs',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      onTap: () async {
        await LogsManager.clearLogs();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          buildCustomSnackBar(
            content: const Text('Successfully deleted all logs'),
          ),
        );
      },
    );
  }
}
