import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/reminder_class/reminder.dart';

extension Archives on RemindersDatabaseController {

  static void archivesDeleteReminder(int id) {
    if (id == reminderNullID)
    {
      throw "[archivesDeleteReminder] Reminder id is reminderNullID";
    }

    final Map<int, Reminder> archives = RemindersDatabaseController.getReminders(key: archivesKey);
    if (archives.containsKey(id)) {
      archives.remove(id);
      RemindersDatabaseController.remindersBox.put(archivesKey, archives);
    }
    else 
    {
      throw "Reminder not found in Archives";
    }
  }

  static void addReminderToArchives(Reminder? reminder) {
    if (reminder != null) {
      final Map<int, Reminder> archives = RemindersDatabaseController.getReminders(key: archivesKey);

      if (reminder.id == null)
      {
        throw "[moveReminderToArchives] Reminder id is null";
      }
      else if (reminder.id == reminderNullID)
      {
        throw "[moveReminderToArchives] Reminder id is reminderNullID";
      }

      archives[reminder.id ?? reminderNullID] = reminder;
      RemindersDatabaseController.remindersBox.put(archivesKey, archives);
    }
    else throw  "[moveReminderToArchives] Reminder is null";
  }
}