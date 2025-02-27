import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../../core/data/models/reminder_model/reminder_model.dart';
import '../../../../core/enums/storage_enums.dart';

class RemindersDatabaseController {
  static final Box<ReminderModel> _box = Hive.box<ReminderModel>(
    HiveBoxNames.reminders.name,
  );

  static Map<int, ReminderModel> getReminders() {
    if (!_box.isOpen) {
      Future<void>(() {
        Hive.openBox<ReminderModel>(HiveBoxNames.reminders.name);
      });
    }

    return Map<int, ReminderModel>.fromEntries(
      _box.keys.map(
        (dynamic key) =>
            MapEntry<int, ReminderModel>(key as int, _box.get(key)!),
      ),
    );
  }

  static Future<void> removeReminder(int id) async {
    await _box.delete(id);
  }

  static Future<void> saveReminder(int id, ReminderModel reminder) async {
    await _box.put(id, reminder);
  }

  static Future<void> updateReminders(
    Map<int, ReminderModel> reminders,
  ) async {
    for (final MapEntry<int, ReminderModel> entry in reminders.entries) {
      await _box.put(entry.key, entry.value);
    }
  }

  static Future<void> removeAllReminders() async {
    await _box.clear();
  }

  static Future<String> getBackup() async {
    final Map<int, ReminderModel> reminders = getReminders();
    final Map<String, dynamic> backupData = <String, dynamic>{
      'reminders': reminders.map(
        (int id, ReminderModel reminder) =>
            MapEntry<String, Map<String, String?>>(
          id.toString(),
          reminder.toJson(),
        ),
      ),
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
    return jsonEncode(backupData);
  }

  static Future<void> restoreBackup(String jsonData) async {
    try {
      final Map<String, dynamic> backupData =
          jsonDecode(jsonData) as Map<String, dynamic>;
      final Map<String, dynamic> remindersData =
          backupData['reminders'] as Map<String, dynamic>;

      final Map<int, ReminderModel> reminders = <int, ReminderModel>{};
      remindersData.forEach((String key, dynamic value) {
        final int id = int.parse(key);
        reminders[id] = ReminderModel.fromJson(
          Map<String, String?>.from(value as Map<dynamic, dynamic>),
        );
      });

      await removeAllReminders();
      await updateReminders(reminders);
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }
}
