import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:Rem/consts/consts.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/reminder_class/reminder.dart';

class RemindersDatabaseController {
  static Map<int, Reminder> reminders = {};
  static final _remindersBox = Hive.box(remindersBoxName);
  static List<int> removedInBackground = [];

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
  static Map<int, Reminder> getReminders() {

    if (!_remindersBox.isOpen)
    {
      Future(
        () {Hive.openBox(remindersBoxName);}
      );
    }

    reminders = _remindersBox.get(remindersBoxKey)?.cast<int, Reminder>() ?? {};
    return reminders;
  }

  static Map<int, Reminder> getArchives() {
    return _remindersBox.get(archivesKey)?.cast<int, Reminder>() ?? {};
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
      debugPrint("[updateReminders] message sending");
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

    debugPrint("[saveReminder] Reminder: Id${reminder.id}, T${reminder.title}, DT${reminder.dateAndTime}");

    printAll("Before Adding");

    if (reminder.id != newReminderID)
    {
      debugPrint("[saveReminder] id : ${reminder.id}");
      NotificationController.cancelScheduledNotification(
        reminder.id.toString()
      );
      deleteReminder(reminder.id!);
    }

    reminder.id = reminder.getID();
    reminders[reminder.id!] = reminder;
    NotificationController.scheduleNotification(reminder);

    updateReminders();
    printAll("After Adding");
  }

  /// Schedule a number of notifications with a time interval after the scheduled
  /// time of the reminder. 
  static void scheduleRepeatedNotifications(Reminder reminder) {
    debugPrint("[scheduleRepeatedNotifications] called");
    var tempDateTime = reminder.dateAndTime;
    for (int i = 1; i <= 5; i++)
    {
      debugPrint("[scheduleRepeatedNotifications] scheduled 1");
      reminder.dateAndTime = reminder.dateAndTime.add(Duration(seconds: 10));
      NotificationController.scheduleNotification(
        reminder, 
        repeatNumber: i
      );
    }
    reminder.dateAndTime = tempDateTime;
  }

  static void moveReminderToArchives(int id) {
    getReminders();

    final reminder = reminders.remove(id);
    if (reminder != null) {
      final Map<int, Reminder> archives = _remindersBox.get(archivesKey)?.cast<int, Reminder>() ?? {};
      archives[id] = reminder;
      _remindersBox.put(archivesKey, archives);
    }
    else throw  "[moveReminderToArchives] Reminder not found";
  }

  /// Remove a reminder's data from the database.
  static void deleteReminder(int id, {bool allRecurringVersions = false}) {  

    getReminders();
    
    printAll("Before Deleting");

    if (!reminders.containsKey(id)) { // Reminder not found in database
      debugPrint("Reminder with ID ($id) does not exist in the map.");
      printAll("After Deleting");
      return;
    } 

    Reminder reminder = reminders[id]!;

    // Have to cancel scheduled notification in all cases.
    NotificationController.cancelScheduledNotification(
      id.toString()
    );

    if ( // Handle Deletion of Non-recurring or latest instance of recurring reminder.
      reminder.recurringFrequency == RecurringFrequency.none || 
      allRecurringVersions
    ) {
      moveReminderToArchives(id);
      // reminders.remove(id);
      updateReminders();
      printAll("After Deleting");
      return;
    }

    DateTime toUpdate = reminder.dateAndTime;
    RecurringFrequency recFrequency= reminder.recurringFrequency;

    if (recFrequency == RecurringFrequency.daily)
    {
      toUpdate = toUpdate.add(Duration(days: 1));
    }
    else if (recFrequency == RecurringFrequency.weekly)
    {
      toUpdate = toUpdate.add(Duration(days: 7));
    }
    else 
    {
      debugPrint("[deleteReminder] Custom Recurring not yet handled");
    }

    reminder.dateAndTime = toUpdate;
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