import 'package:Rem/consts/consts.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ArchivesDatabase {

  static final _box = Hive.box(archivesBoxName);

  // Check if box is open and not and retrieve the reminders
  static Map<int, Reminder> getArchivedReminders({String key = archivesKey}) {
    if (!_box.isOpen)
    {
      Future(
        () {Hive.openBox(archivesBoxName);}
      );
    }

      final Map<int, Reminder> reminders = _box.get(archivesKey)?.cast<int, Reminder>() ?? {};
    return reminders;
  }

  static void _putArchivedReminders(Map<int, Reminder> reminders, {String key = archivesKey}) {
    if (!_box.isOpen)
    {
      Future(
        () {Hive.openBox(remindersBoxName);}
      );
    }

    _box.put(key, reminders);
  }

  static void deleteArchivedReminder(int id) {
    if (id == reminderNullID)
    {
      throw "[archivesDeleteReminder] Reminder id is reminderNullID";
    }

    final Map<int, Reminder> archives = getArchivedReminders();
    if (archives.containsKey(id)) {

      viewAllArchivedReminders("Before Removing from Archives");

      archives.remove(id);
      _putArchivedReminders(archives);

      viewAllArchivedReminders("After Removing from Archives");
    }

    else 
    {
      throw "Reminder not found in Archives";
    }
  }

  static void addReminderToArchives(Reminder? reminder) {
    if (reminder != null) {
      reminder.reminderStatus = ReminderStatus.archived;
      final Map<int, Reminder> archives = getArchivedReminders();

      viewAllArchivedReminders("Before Adding in Archives");

      if (reminder.id == null)
      {
        throw "[moveReminderToArchives] Reminder id is null";
      }
      else if (reminder.id == reminderNullID)
      {
        throw "[moveReminderToArchives] Reminder id is reminderNullID";
      }

      archives[reminder.id ?? reminderNullID] = reminder;
      _putArchivedReminders(archives);

      viewAllArchivedReminders("After Adding in Archives");
    }
    else throw  "[moveReminderToArchives] Reminder is null";
  }

  static void viewAllArchivedReminders(String str) {
    final map = getArchivedReminders();

    if (map.isEmpty)
    {
      print("No reminders in Archives");
      return;
    }
  }
}