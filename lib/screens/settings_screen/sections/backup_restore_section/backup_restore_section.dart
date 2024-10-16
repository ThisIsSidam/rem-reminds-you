import 'dart:convert';
import 'dart:io';

import 'package:Rem/database/archives_database.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/widgets/snack_bar/custom_snack_bar.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class BackupRestoreSection extends StatelessWidget {
  const BackupRestoreSection({super.key});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Backup & Restore (Experimental)",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Colors.white
            ),
          ),
          SizedBox(height: 5),
          Column(
            children: [
              SizedBox(height: 10),
              getBackupTile(context),
              SizedBox(height: 10),
              getRestoreTile(context),
              SizedBox(height: 20),
            ],
          )
        ],
      ), 
    );
  }

  Widget getBackupTile(BuildContext context) {
    return ListTile(
      title: Text(
        'Backup',
        style: Theme.of(context).textTheme.titleSmall
      ),
      onTap: () async {
        var status2 = await Permission.manageExternalStorage.request();
        if (!status2.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(
              content: Text('Storage2 permission is required for backup')
            ),
          );
          return;
        }

        try {
          String remindersJsonData = await RemindersDatabaseController.getBackup();
          String archivesJsonData = await Archives.getBackup();

          // Create a temporary zip file in memory
          final archive = Archive();
          archive.addFile(ArchiveFile('reminders_backup.json', remindersJsonData.length, utf8.encode(remindersJsonData)));
          archive.addFile(ArchiveFile('archives_backup.json', archivesJsonData.length, utf8.encode(archivesJsonData)));
          final zipData = ZipEncoder().encode(archive);

          if (zipData == null || zipData.isEmpty) {
            debugPrint('zipData is null or empty');
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
          print('Error during backup: $e');
          print('Stack trace: $stackTrace');
          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(content: Text('Backup failed: ${e.toString()}')),
          );
        }
      },
    );
  }
  
  Widget getRestoreTile(BuildContext context) {
    return ListTile(
      title: Text(
        'Restore',
        style: Theme.of(context).textTheme.titleSmall
      ),
      onTap: () async {
        var status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(
              content: Text('Storage permission is required for restore')
            ),
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
            debugPrint('reminders_backup.json not found in the zip file');
          } else {
            final remindersJsonContent = utf8.decode(remindersJsonFile.content);
            RemindersDatabaseController.restoreBackup(remindersJsonContent);
          }

          final archivesJsonFile = archive.findFile('archives_backup.json');
          if (archivesJsonFile == null) {
            debugPrint('archives_backup.json not found in the zip file');
          } else {
            final archivesJsonContent = utf8.decode(archivesJsonFile.content);
            Archives.restoreBackup(archivesJsonContent);
          }
          


          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(content: Text('Backup restored successfully')),
          );
        } catch (e, stackTrace) {
          print('Error during restore: $e');
          print('Stack trace: $stackTrace');
          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(content: Text('Restore failed: ${e.toString()}')),
          );
        }
      }
    );
  }
}