import 'dart:convert';

import 'package:Rem/consts/enums/hive_enums.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../modals/reminder_modal/reminder_modal.dart';

class RemindersDatabaseController {
  static final _remindersBox = Hive.box(HiveBoxNames.reminders.name);

  static Map<int, ReminderModal> getReminders() {
    if (!_remindersBox.isOpen) {
      Future(() {
        Hive.openBox(HiveBoxNames.reminders.name);
      });
    }

    return _remindersBox
            .get(HiveKeys.remindersBoxKey.key)
            ?.cast<int, ReminderModal>() ??
        {};
  }

  static Future<void> updateReminders(Map<int, ReminderModal> reminders) async {
    await _remindersBox.put(HiveKeys.remindersBoxKey.key, reminders);
  }

  static void removeAllReminders() {
    _remindersBox.put(HiveKeys.remindersBoxKey.key, {});
  }

  static Future<String> getBackup() async {
    Map<int, ReminderModal> reminders = getReminders();
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

      Map<int, ReminderModal> reminders = {};
      remindersData.forEach((key, value) {
        int id = int.parse(key);
        value = value.cast<String, String?>();
        reminders[id] = ReminderModal.fromJson(value);
      });

      removeAllReminders();
      updateReminders(reminders);
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }
}
