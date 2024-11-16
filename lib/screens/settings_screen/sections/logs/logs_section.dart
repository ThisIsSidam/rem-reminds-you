import 'dart:io';

import 'package:Rem/widgets/snack_bar/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          final File srcFile = File('${storage.path}/app_logs.txt');

          Directory extStorage = Directory('storage/emulated/0/Download');
          if (extStorage.existsSync() == false) {
            extStorage.createSync();
          }

          final outputFile = File('${extStorage.path}/rem_logs.txt');
          await srcFile.copy(outputFile.path);

          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(
                content: Text('Backup created: ${outputFile.path}')),
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
}
