import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/notification/notification.dart';
import 'package:nagger/reminder_class/reminder.dart';

class RemindersDatabaseController {
  static Map<int, Reminder> reminders = {};
  static final _remindersBox = Hive.box(remindersBoxName);
  static List<int> removedInBackground = [];


  /// Removes the reminders from the database which were set as 'done' in their 
  /// notifications when the app was terminated.
  static Future<void> clearPendingRemovals() async {
    debugPrint("[clearPendingRemovals] Running");
    final pendingRemovals = await Hive.openBox(pendingRemovalsBoxName);

    debugPrint("[clearPendingRemovals] Box opened");
    final removals = pendingRemovals.get(pendingRemovalsBoxKey) ?? [];
    for (final id in removals) 
    {
      debugPrint("[clearPendingRemovals] Removing $id");
      deleteReminder(id);
    }
    pendingRemovals.put(pendingRemovalsBoxKey, []);
    debugPrint("[clearPendingRemovals] Removing Done");
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

  static Map<int, Map<String, dynamic>> getRemindersAsMaps() {
    final reminders = getReminders();
    return reminders.map((key, value) => MapEntry(key, value.toMap()));  
  }

  /// Update reminders to the database.
  static void updateReminders() async {
    _remindersBox.put(remindersBoxKey, reminders);

    final SendPort? backgroundIsolate = IsolateNameServer.lookupPortByName(bg_isolate_name);
    if (backgroundIsolate != null) 
    {
      debugPrint("[updateReminders] message sending");
      final message = RemindersDatabaseController.getRemindersAsMaps();

      if (_remindersBox.length == 1)
      {
        // Length 1 means the service was closed before this reminder was saved.
        debugPrint("[updateReminders] starting bg service");
        await FlutterBackgroundService().startService();
      }

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

  /// Remove a reminder's data from the database.
  static void deleteReminder(int id) {  

    getReminders();
    
    printAll("Before Deleting");

    if (!reminders.containsKey(id)) {
      print("Reminder with ID ($id) does not exist in the map.");
      printAll("After Deleting");
      return;
    } 

    Reminder reminder = reminders[id]!;

    if (reminder.recurringFrequency == RecurringFrequency.none)
    {
      reminders.remove(id);
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

    for (final reminder in remindersList)
    {
      Duration due = reminder.getDiffDuration();
      if (due.isNegative)
      {
        overdueList.add(reminder);
      }
      else if (due.inHours < 24) 
      {
        todayList.add(reminder);
      }
      else if (due.inHours < 48)
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