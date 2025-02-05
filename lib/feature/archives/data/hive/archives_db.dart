import 'dart:convert';

import 'package:Rem/core/enums/hive_enums.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../../core/models/reminder_model/reminder_model.dart';

class ArchivesDatabaseController {
  static final _box = Hive.box(HiveBoxNames.archives.name);

  static Map<int, ReminderModel> getArchivedReminders() {
    if (!_box.isOpen) {
      Future(() {
        Hive.openBox(HiveBoxNames.archives.name);
      });
    }
    return _box.get(HiveKeys.archivesKey.key)?.cast<int, ReminderModel>() ?? {};
  }

  static Future<void> updateArchivedReminders(
      Map<int, ReminderModel> reminders) async {
    await _box.put(HiveKeys.archivesKey.key, reminders);
  }

  static Future<void> removeAllArchivedReminders() async {
    await _box.put(HiveKeys.archivesKey.key, {});
  }

  static Future<String> getBackup() async {
    Map<int, ReminderModel> reminders = getArchivedReminders();
    Map<String, dynamic> backupData = {
      'reminders': reminders
          .map((id, reminder) => MapEntry(id.toString(), reminder.toJson())),
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
    return jsonEncode(backupData);
  }

  static Future<void> restoreBackup(String jsonData) async {
    try {
      Map<String, dynamic> backupData = jsonDecode(jsonData);
      Map<String, dynamic> remindersData = backupData['reminders'];

      Map<int, ReminderModel> reminders = {};
      remindersData.forEach((key, value) {
        int id = int.parse(key);
        value = value.cast<String, String?>();
        reminders[id] = ReminderModel.fromJson(value);
      });

      await removeAllArchivedReminders();
      await updateArchivedReminders(reminders);
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }
}
