import 'dart:convert';

import 'package:Rem/core/enums/hive_enums.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/models/basic_reminder_model.dart';

class RemindersDatabaseController {
  static final _remindersBox = Hive.box(HiveBoxNames.reminders.name);

  static Map<int, BasicReminderModel> getReminders() {
    if (!_remindersBox.isOpen) {
      Future(() {
        Hive.openBox(HiveBoxNames.reminders.name);
      });
    }

    return _remindersBox
            .get(HiveKeys.remindersBoxKey.key)
            ?.cast<int, BasicReminderModel>() ??
        {};
  }

  static Future<void> updateReminders(
      Map<int, BasicReminderModel> reminders) async {
    await _remindersBox.put(HiveKeys.remindersBoxKey.key, reminders);
  }

  static void removeAllReminders() {
    _remindersBox.put(HiveKeys.remindersBoxKey.key, {});
  }

  static Future<String> getBackup() async {
    Map<int, BasicReminderModel> reminders = getReminders();
    Map<String, dynamic> backupData = {
      'reminders': reminders
          .map((id, reminder) => MapEntry(id.toString(), reminder.toJson())),
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
    return jsonEncode(backupData);
  }

  static void restoreBackup(String jsonData) {
    try {
      Map<String, dynamic> backupData = jsonDecode(jsonData);
      Map<String, dynamic> remindersData = backupData['reminders'];

      Map<int, BasicReminderModel> reminders = {};
      remindersData.forEach((key, value) {
        int id = int.parse(key);
        value = value.cast<String, String?>();
        reminders[id] = BasicReminderModel.fromJson(value);
      });

      removeAllReminders();
      updateReminders(reminders);
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }
}
