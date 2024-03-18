import 'package:hive_flutter/hive_flutter.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/notification/notification.dart';
import 'package:nagger/reminder_class/reminder.dart';

class RemindersDatabaseController {
  static Map<int, Reminder> reminders = {};
  static final _remindersBox = Hive.box(remindersBoxName);
  static List<int> removedInBackground = [];

  static Future<void> clearPendingRemovals() async {
    final pendingRemovals = await Hive.openBox(pendingRemovalsBoxKey);

    final removals = pendingRemovals.get(pendingRemovalsBoxKey) ?? [];
    for (final id in removals) 
    {
      deleteReminder(id);
    }
    pendingRemovals.put(pendingRemovalsBoxKey, []);
  }

  static void getReminders() { 
    reminders = _remindersBox.get(remindersBoxKey)?.cast<int, Reminder>() ?? {};
  }

  static void updateReminders() {
    _remindersBox.put(remindersBoxKey, reminders);
  }

  static int getNumberOfReminders() {
    getReminders();
    return reminders.length;
  }

  static void saveReminder(Reminder reminder) {
    getReminders();

    printAll("Before Adding");

    if (reminder.id != 101)
    {
      NotificationController.cancelScheduledNotification(
        reminder.id ?? reminderNullID
      );
      deleteReminder(reminder.id!);
    }

    reminder.id = reminder.getID();
    reminders[reminder.id!] = reminder;
    NotificationController.scheduleNotification(
      reminder.id ?? reminderNullID,
      reminder.title ?? reminderNullTitle,
      reminder.dateAndTime
    );
    
    updateReminders();
    printAll("After Adding");

  }

  static void deleteReminder(int id) {  

    getReminders();
    
    printAll("Before Deleting");
    if (reminders.containsKey(id)) {
      reminders.remove(id);
      updateReminders();
    } else {
      print("Reminder with ID ($id) does not exist in the map.");
    }
    printAll("After Deleting");
  }

  static void printAll(String str) {
    getReminders();

    print(str);
    print("================");

    reminders.forEach((key, value) {
      print("Key: ($key)");
    });
  }

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