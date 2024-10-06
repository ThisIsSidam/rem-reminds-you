import 'dart:convert';

import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/archives_database.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/generate_id.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../reminder_class/field_mixins/reminder_status/status.dart';

class RemindersDatabaseController {
  static Map<int, Reminder> reminders = {};
  static final _remindersBox = Hive.box(remindersBoxName);
  static List<int> removedInBackground = [];

  static Box<dynamic> get remindersBox => _remindersBox;

  /// Removes the reminders from the database which were set as 'done' in their 
  /// notifications when the app was terminated.
  static Future<void> clearPendingRemovals() async {
    final pendingRemovals = await Hive.openBox(pendingRemovalsBoxName);

    final removals = pendingRemovals.get(pendingRemovalsBoxKey) ?? [];
    for (final id in removals) 
    {
      markAsDone(id);
    }
    pendingRemovals.put(pendingRemovalsBoxKey, []);
  }

  static void removeAllReminders() {
    _remindersBox.put(remindersBoxKey, {});
  }

  /// Get reminders from the database.
  static Map<int, Reminder> getReminders({key = remindersBoxKey}) {

    if (!_remindersBox.isOpen)
    {
      Future(
        () {Hive.openBox(remindersBoxName);}
      );
    }

    reminders = _remindersBox.get(key)?.cast<int, Reminder>() ?? {};
    return reminders;
  }

  static Map<int, Map<String, String?>> getRemindersAsMaps() {
    final reminders = getReminders();
    return reminders.map((key, value) => MapEntry(key, value.toMap()));  
  }

  static Reminder? getReminder(int id) {
    getReminders();
    return reminders[id];
  }

  /// Update reminders to the database.
  static void updateReminders() async {
    _remindersBox.put(remindersBoxKey, reminders);
  }

  /// Number of reminders present in the database.
  static int getNumberOfReminders() {
    getReminders();
    return reminders.length;
  }

  /// Add a reminder to the database.
  static void saveReminder(Reminder reminder) {
    getReminders();

    printAll("Before Saving");

    if (reminder.id == null)
    {
      throw "[saveReminder] Reminder id is null";
    }
    else if 
    (
      // Upon edits, we delete the previous version and create an entirely new one
      reminder.id != newReminderID && // New Reminders wouldn't be present in database
      reminder.reminderStatus != ReminderStatus.archived // Archived reminders would be present only in Archived Database
    ) 
    {
      debugPrint("[saveReminder] id : ${reminder.id}");
      NotificationController.cancelScheduledNotification(
        reminder.id.toString()
      );
      reminders.remove(reminder.id);
    }

    if (reminder.reminderStatus == ReminderStatus.archived) // Moving from archives to main reminder database.
    {
      retrieveFromArchives(reminder);
      return;
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

    updateReminders();
    printAll("After Adding");
  }

  static Reminder? _getReminder(int id) {
    getReminders();
    if (reminders.containsKey(id)){
      return reminders[id]!;
    } else {
      return null;
    }
  }

  static void retrieveFromArchives(Reminder reminder) {
    Archives.deleteArchivedReminder(reminder.id!);
    NotificationController.scheduleNotification(reminder);
    reminder.reminderStatus = ReminderStatus.active;
    reminders[reminder.id!] = reminder;
    updateReminders();
    printAll("After Saving");
  }

  static void markAsDone(int id) {
    final Reminder? reminder = _getReminder(id);
    if (reminder == null) {
      debugPrint("[markAsDone] Reminder not found in database");
      return;
    }

    if (reminder.recurringInterval == RecurringInterval.none) {
      moveToArchive(id);
    } else {
      moveToNextReminderOccurence(id);
    }
  }

  /// Moves the reminder to Archives.
  static void moveToArchive(int id) {  
    final Reminder? reminder = _getReminder(id);
    if (reminder == null) {
      debugPrint("[moveToArchives] Reminder not found in database");
      return;
    }    

    // Have to cancel scheduled notification in all cases.
    NotificationController.cancelScheduledNotification(
      id.toString()
    );

    reminders.remove(id);
    Archives.addReminderToArchives(reminder);
    updateReminders();
    printAll("After Archiving");
  }

  static void moveToNextReminderOccurence(int id) {
    final Reminder? reminder = _getReminder(id);
    if (reminder == null) {
      throw "[moveToNextReminderIteration] Reminder not found in database";
    }

    // Have to cancel scheduled notification in all cases.
    NotificationController.cancelScheduledNotification(
      id.toString()
    );

    reminder.moveToNextOccurence();
    NotificationController.scheduleNotification(reminder);
    reminders[id] = reminder;
    updateReminders();
    printAll('After Skipping');
  }

  static void moveToPreviousReminderOccurence(int id) {
    final Reminder? reminder = _getReminder(id);
    if (reminder == null) {
      throw "[moveToNextReminderIteration] Reminder not found in database";
    }

    // Have to cancel scheduled notification in all cases.
    NotificationController.cancelScheduledNotification(
      id.toString()
    );

    reminder.moveToPreviousOccurence();
    NotificationController.scheduleNotification(reminder);
    reminders[id] = reminder;
    updateReminders();
    printAll('After Skipping');
  }

  static void deleteReminder(int id, {bool allRecurringVersions = false}) {
    final Reminder? reminder = _getReminder(id);
    if (reminder == null) {
      debugPrint("[deleteReminder] Reminder not found in database");
      return;
    }
    
    NotificationController.cancelScheduledNotification(id.toString());
    reminders.remove(id);
    updateReminders();
    printAll('After Deleting');
  }

  /// Print id of all the reminders which are present in the database.
  static void printAll(String str) {
    getReminders();

    debugPrint(str);
    debugPrint("================");

    reminders.forEach((key, value) {
      debugPrint("Key: ($key)");
    });
  }

  /// Returns a map which consists of all the reminders in the database categorized
  /// as per their time. The categories are Overdue, Today, Tomorrow and Later.
  static Map<String,List<Reminder>> getReminderLists() {
    getReminders();
    final remindersList = reminders.values.toList();

    final overdueList = <Reminder>[];
    final todayList = <Reminder>[];
    final tomorrowList = <Reminder>[];
    final laterList = <Reminder>[];

    remindersList.sort((a, b) => a.getDiffDuration().compareTo(b.getDiffDuration()));

    final now = DateTime.now();


    for (final reminder in remindersList)
    {
      DateTime dateTime = reminder.dateAndTime;
      if (dateTime.isBefore(now))
      {
        overdueList.add(reminder);
      }
      else if (dateTime.day == now.day && dateTime.month == now.month && dateTime.year == now.year) 
      {
        todayList.add(reminder);
      }
      else if (dateTime.day == now.day+1 && dateTime.month == now.month && dateTime.year == now.year)
      {
        tomorrowList.add(reminder);
      }
      else
      {
        laterList.add(reminder);
      }
    };

    return {
      overdueSectionTitle : overdueList,
      todaySectionTitle : todayList,
      tomorrowSectionTitle : tomorrowList,
      laterSectionTitle : laterList
    };
  }

  static Future<String> getBackup() async {
    // Get the map of reminders
    Map<int, Reminder> reminders = await getReminders();

    // Convert the reminders to a format suitable for JSON
    Map<String, dynamic> backupData = {
      'reminders': reminders.map((id, reminder) => MapEntry(id.toString(), reminder.toMap())),
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