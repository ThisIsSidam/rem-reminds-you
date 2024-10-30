import 'dart:convert';

import 'package:Rem/consts/enums/hive_enums.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../reminder_class/reminder.dart';

class RemindersDatabaseController {
  static final _remindersBox = Hive.box(HiveBoxNames.reminders.name);

  static Map<int, Reminder> getReminders() {
    if (!_remindersBox.isOpen) {
      Future(() {
        Hive.openBox(HiveBoxNames.reminders.name);
      });
    }

    return _remindersBox
            .get(HiveKeys.remindersBoxKey.key)
            ?.cast<int, Reminder>() ??
        {};
  }

  static void updateReminders(Map<int, Reminder> reminders) async {
    await _remindersBox.put(HiveKeys.remindersBoxKey.key, reminders);
  }

  static void removeAllReminders() {
    _remindersBox.put(HiveKeys.remindersBoxKey.key, {});
  }

  static Future<String> getBackup() async {
    Map<int, Reminder> reminders = getReminders();
    Map<String, dynamic> backupData = {
      'reminders': reminders
          .map((id, reminder) => MapEntry(id.toString(), reminder.toMap())),
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
    return jsonEncode(backupData);
  }

  static void restoreBackup(String jsonData) {
    try {
      Map<String, dynamic> backupData = jsonDecode(jsonData);
      Map<String, dynamic> remindersData = backupData['reminders'];

      Map<int, Reminder> reminders = {};
      remindersData.forEach((key, value) {
        int id = int.parse(key);
        value = value.cast<String, String?>();
        reminders[id] = Reminder.fromMap(value);
      });

      removeAllReminders();
      updateReminders(reminders);
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }
}
