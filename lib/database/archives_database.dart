import 'dart:convert';

import 'package:Rem/consts/consts.dart';
import 'package:Rem/consts/enums/hive_enums.dart';
import 'package:Rem/reminder_class/field_mixins/reminder_status/status.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Archives {
  static final _box = Hive.box(HiveBoxNames.archives.name);

  // Check if box is open and not and retrieve the reminders
  static Map<int, Reminder> getArchivedReminders() {
    if (!_box.isOpen) {
      Future(() {
        Hive.openBox(HiveBoxNames.archives.name);
      });
    }

    final Map<int, Reminder> reminders =
        _box.get(HiveKeys.archivesKey.key)?.cast<int, Reminder>() ?? {};
    return reminders;
  }

  static void removeAllArchivedReminders() {
    _box.put(HiveKeys.archivesKey.key, {});
  }

  static void _putArchivedReminders(
    Map<int, Reminder> reminders,
  ) {
    if (!_box.isOpen) {
      Future(() {
        Hive.openBox(HiveBoxNames.reminders.name);
      });
    }

    _box.put(HiveKeys.archivesKey.key, reminders);
  }

  static void deleteArchivedReminder(int id) {
    if (id == reminderNullID) {
      throw "[archivesDeleteReminder] Reminder id is reminderNullID";
    }

    final Map<int, Reminder> archives = getArchivedReminders();
    if (archives.containsKey(id)) {
      viewAllArchivedReminders("Before Removing from Archives");

      archives.remove(id);
      _putArchivedReminders(archives);

      viewAllArchivedReminders("After Removing from Archives");
    } else {
      throw "Reminder not found in Archives";
    }
  }

  static void addReminderToArchives(Reminder? reminder) {
    if (reminder != null) {
      reminder.reminderStatus = ReminderStatus.archived;
      final Map<int, Reminder> archives = getArchivedReminders();

      viewAllArchivedReminders("Before Adding in Archives");

      if (reminder.id == null) {
        throw "[moveReminderToArchives] Reminder id is null";
      } else if (reminder.id == reminderNullID) {
        throw "[moveReminderToArchives] Reminder id is reminderNullID";
      }

      archives[reminder.id ?? reminderNullID] = reminder;
      _putArchivedReminders(archives);

      viewAllArchivedReminders("After Adding in Archives");
    } else
      throw "[moveReminderToArchives] Reminder is null";
  }

  static void viewAllArchivedReminders(String str) {
    final map = getArchivedReminders();

    if (map.isEmpty) {
      print("No reminders in Archives");
      return;
    }
  }

  static Future<String> getBackup() async {
    // Get the map of reminders
    Map<int, Reminder> reminders = getArchivedReminders();

    // Convert the reminders to a format suitable for JSON
    Map<String, dynamic> backupData = {
      'reminders': reminders
          .map((id, reminder) => MapEntry(id.toString(), reminder.toMap())),
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0', // You might want to include an app or backup version
    };

    // Convert the backup data to JSON
    String jsonData = jsonEncode(backupData);

    return jsonData;
  }

  static void restoreBackup(String jsonData) {
    try {
      // Parse the JSON data
      Map<String, dynamic> backupData = jsonDecode(jsonData);

      // Extract the reminders data
      Map<String, dynamic> remindersData = backupData['reminders'];

      // Convert the reminders data back to a Map<int, Reminder>
      Map<int, Reminder> reminders = {};
      remindersData.forEach((key, value) {
        int id = int.parse(key);
        value = value.cast<String, String?>();
        reminders[id] = Reminder.fromMap(value);
      });

      // Clear existing reminders (if needed)
      removeAllArchivedReminders();

      // Save the restored reminders
      for (var reminder in reminders.values) {
        addReminderToArchives(reminder);
      }

      print('Backup restored successfully');
      print('Restored ${reminders.length} reminders');
      print('Backup timestamp: ${backupData['timestamp']}');
      print('Backup version: ${backupData['version']}');
    } catch (e) {
      print('Error restoring backup: $e');
      throw Exception('Failed to restore backup: $e');
    }
  }
}
