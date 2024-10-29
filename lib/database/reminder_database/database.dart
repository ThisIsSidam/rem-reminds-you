import 'dart:convert';

import 'package:Rem/consts/consts.dart';
import 'package:Rem/consts/enums/hive_enums.dart';
import 'package:Rem/database/archives_database.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/generate_id.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../reminder_class/field_mixins/reminder_status/status.dart';

class RemindersDatabaseController {
  static final _remindersBox = Hive.box(HiveBoxNames.reminders.name);
  static List<int> removedInBackground = [];

  static Box<dynamic> get remindersBox => _remindersBox;

  /// Get reminders from the database.
  static Map<int, Reminder> getReminders() {
    if (!_remindersBox.isOpen) {
      Future(() {
        Hive.openBox(HiveBoxNames.reminders.name);
      });
    }

    final Map<int, Reminder> reminders = _remindersBox
            .get(HiveKeys.remindersBoxKey.key)
            ?.cast<int, Reminder>() ??
        {};
    return reminders;
  }

  static Map<int, Map<String, String?>> getRemindersAsMaps() {
    final reminders = getReminders();
    return reminders.map((key, value) => MapEntry(key, value.toMap()));
  }

  static Reminder? getReminder(int id) {
    final reminders = getReminders();
    return reminders[id];
  }

  /// Number of reminders present in the database.
  static int getNumberOfReminders() {
    final reminders = getReminders();
    return reminders.length;
  }

  /// Update reminders to the database.
  static void updateReminders(Map<int, Reminder> reminders) async {
    _remindersBox.put(HiveKeys.remindersBoxKey.key, reminders);
  }

  /// Add a reminder to the database.
  static void saveReminder(Reminder reminder) {
    final reminders = getReminders();
    final updatedReminders = _handleSave(reminders, reminder);
    updateReminders(updatedReminders);
  }

  static void removeAllReminders() {
    _remindersBox.put(HiveKeys.remindersBoxKey.key, {});
  }

  static void deleteReminder(int id, {bool allRecurringVersions = false}) {
    final Reminder? reminder = getReminder(id);
    if (reminder == null) {
      debugPrint("[deleteReminder] Reminder not found in database");
      return;
    }

    NotificationController.cancelScheduledNotification(id.toString());
    NotificationController.removeNotifications(id.toString());
    final reminders = getReminders();
    reminders.remove(id);
    updateReminders(reminders);
  }

  /// Removes the reminders from the database which were set as 'done' in their
  /// notifications when the app was terminated.
  static Future<void> clearPendingRemovals() async {
    final pendingRemovals =
        await Hive.openBox(HiveBoxNames.pendingRemovalsBoxName.name);

    final removals =
        pendingRemovals.get(HiveKeys.pendingRemovalsBoxKey.key) ?? [];
    for (final id in removals) {
      markAsDone(id);
    }
    pendingRemovals.put(HiveKeys.pendingRemovalsBoxKey.key, []);
  }

  static void markAsDone(int id) {
    final Reminder? reminder = getReminder(id);
    if (reminder == null) {
      debugPrint("[markAsDone] Reminder not found in database");
      return;
    }

    if (reminder.recurringInterval == RecurringInterval.none) {
      moveToArchive(id);
    } else {
      moveToNextReminderOccurrence(id);
    }

    NotificationController.removeNotifications(id.toString());
  }

  /// Moves the reminder to Archives.
  static void moveToArchive(int id) {
    final Reminder? reminder = getReminder(id);
    if (reminder == null) {
      debugPrint("[moveToArchives] Reminder not found in database");
      return;
    }

    // Have to cancel scheduled notification in all cases.
    NotificationController.cancelScheduledNotification(id.toString());

    Archives.addReminderToArchives(reminder);
    deleteReminder(id);
  }

  static void moveToNextReminderOccurrence(int id) {
    final Reminder? reminder = getReminder(id);
    if (reminder == null) {
      throw "[moveToNextReminderIteration] Reminder not found in database";
    }

    // Have to cancel scheduled notification in all cases.
    NotificationController.cancelScheduledNotification(id.toString());

    reminder.moveToNextOccurence();
    NotificationController.scheduleNotification(reminder);
    final reminders = getReminders();
    reminders[id] = reminder;
    updateReminders(reminders);
  }

  static void moveToPreviousReminderOccurrence(int id) {
    final Reminder? reminder = getReminder(id);
    if (reminder == null) {
      throw "[moveToNextReminderIteration] Reminder not found in database";
    }

    // Have to cancel scheduled notification in all cases.
    NotificationController.cancelScheduledNotification(id.toString());

    reminder.moveToPreviousOccurence();
    NotificationController.scheduleNotification(reminder);
    final reminders = getReminders();
    reminders[id] = reminder;
    updateReminders(reminders);
  }

  static Map<int, Reminder> _handleSave(
      Map<int, Reminder> reminders, Reminder reminder) {
    if (reminder.id == null) {
      throw "[saveReminder] Reminder id is null";
    } else if (
        // Upon edits, we delete the previous version and create an entirely new one
        reminder.id != newReminderID && // Check for new reminders
            reminder.reminderStatus !=
                ReminderStatus.archived // Check for archived reminders
        ) {
      NotificationController.cancelScheduledNotification(
          reminder.id.toString());
      reminders.remove(reminder.id);
    }
    // Moving from archives to main reminder database.
    if (reminder.reminderStatus == ReminderStatus.archived) {
      return retrieveFromArchives(reminder);
    }

    // Setup for new reminder
    int? id = reminder.id;
    if (id == null || id == reminderNullID || id == newReminderID) {
      id = generateId(reminder);
      reminder.baseDateTime = reminder.dateAndTime;
    }

    reminder.id = id;
    reminders[reminder.id!] = reminder;
    NotificationController.scheduleNotification(reminder);
    return reminders;
  }

  static Map<int, Reminder> retrieveFromArchives(Reminder reminder) {
    Archives.deleteArchivedReminder(reminder.id!);
    NotificationController.scheduleNotification(reminder);
    reminder.reminderStatus = ReminderStatus.active;
    final reminders = getReminders();
    reminders[reminder.id!] = reminder;
    updateReminders(reminders);
    return reminders;
  }

  /// Returns a map which consists of all the reminders in the database categorized
  /// as per their time. The categories are Overdue, Today, Tomorrow and Later.
  static Map<String, List<Reminder>> getReminderLists() {
    final reminders = getReminders();
    final remindersList = reminders.values.toList();

    final overdueList = <Reminder>[];
    final todayList = <Reminder>[];
    final tomorrowList = <Reminder>[];
    final laterList = <Reminder>[];

    remindersList
        .sort((a, b) => a.getDiffDuration().compareTo(b.getDiffDuration()));

    final now = DateTime.now();

    for (final reminder in remindersList) {
      DateTime dateTime = reminder.dateAndTime;
      if (dateTime.isBefore(now)) {
        overdueList.add(reminder);
      } else if (dateTime.day == now.day &&
          dateTime.month == now.month &&
          dateTime.year == now.year) {
        todayList.add(reminder);
      } else if (dateTime.day == now.day + 1 &&
          dateTime.month == now.month &&
          dateTime.year == now.year) {
        tomorrowList.add(reminder);
      } else {
        laterList.add(reminder);
      }
    }
    ;

    return {
      overdueSectionTitle: overdueList,
      todaySectionTitle: todayList,
      tomorrowSectionTitle: tomorrowList,
      laterSectionTitle: laterList
    };
  }

  static Future<String> getBackup() async {
    // Get the map of reminders
    Map<int, Reminder> reminders = await getReminders();

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
      removeAllReminders();

      // Save the restored reminders
      for (var reminder in reminders.values) {
        saveReminder(reminder);
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
