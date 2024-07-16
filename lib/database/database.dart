import 'dart:isolate';
import 'dart:ui';
import 'package:Rem/database/archives_database.dart';
import 'package:Rem/utils/other_utils/generate_id.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:Rem/consts/consts.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/reminder_class/reminder.dart';

class RemindersDatabaseController {
  static Map<int, Reminder> reminders = {};
  static final _remindersBox = Hive.box(remindersBoxName);
  static List<int> removedInBackground = [];

  static Box<dynamic> get remindersBox => _remindersBox;

  /// Removes the reminders from the database which were set as 'done' in their 
  /// notifications when the app was terminated.
  static Future<void> clearPendingRemovals() async {
    // debugPrint("[clearPendingRemovals] Running");
    final pendingRemovals = await Hive.openBox(pendingRemovalsBoxName);

    // debugPrint("[clearPendingRemovals] Box opened");
    final removals = pendingRemovals.get(pendingRemovalsBoxKey) ?? [];
    for (final id in removals) 
    {
      // debugPrint("[clearPendingRemovals] Removing $id");
      deleteReminder(id);
    }
    pendingRemovals.put(pendingRemovalsBoxKey, []);
    // debugPrint("[clearPendingRemovals] Removing Done");
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

  static Map<int, Map<String, dynamic>> getRemindersAsMaps() {
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

    final SendPort? backgroundIsolate = IsolateNameServer.lookupPortByName(bg_isolate_name);
    if (backgroundIsolate != null) 
    {
      final message = RemindersDatabaseController.getRemindersAsMaps();

      backgroundIsolate.send(message);
    }
    else
    {
      debugPrint("[updateReminders] background Isolate is null");
    }
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
      ArchivesDatabase.deleteArchivedReminder(reminder.id!);
      reminder.reminderStatus = ReminderStatus.active;
      reminders[reminder.id!] = reminder;
      updateReminders();
      printAll("After Saving");
      return;
    }


    // Manage id. Get new only if current is null or new.
    int? id = reminder.id;
    if (id == null || id == reminderNullID || id == newReminderID) {
      id = generateId(reminder);
    }

    reminder.id = id;
    reminders[reminder.id!] = reminder;
    NotificationController.scheduleNotification(reminder);

    updateReminders();
    printAll("After Adding");
  }

  /// Does not actually delete. Moves the reminder to Archives.
  static void deleteReminder(int id, {bool allRecurringVersions = false}) {  

    getReminders();
    
    printAll("Before Deleting");

    if (!reminders.containsKey(id)) { // Reminder not found in database
      printAll("After Deleting");
      throw "[homepageDeleteReminder] Reminder not found in database";
    } 

    Reminder reminder = reminders[id]!;

    // Have to cancel scheduled notification in all cases.
    NotificationController.cancelScheduledNotification(
      id.toString()
    );

    if ( // Handle Deletion of Non-recurring or all recurrence of recurring reminder.
      reminder.recurringInterval == RecurringInterval.none || 
      allRecurringVersions
    ) {
      reminders.remove(id);

      ArchivesDatabase.addReminderToArchives(reminder);
      
      updateReminders();
      printAll("After Deleting");
      return;
    }

    // Handle moving-up recurring reminder to next recurring date-time and saving it in db..
    reminder.incrementRepeatDuration();
    NotificationController.scheduleNotification(reminder); // Schedule with updated time.
    reminders[id] = reminder;
    updateReminders();
    printAll("After Deleting");
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
}