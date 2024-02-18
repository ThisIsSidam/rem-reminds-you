import 'package:hive_flutter/hive_flutter.dart';
import 'package:nagger/reminder_class/reminder.dart';

class RemindersData {
  Map<int, Reminder> reminders = {};
  final _remindersBox = Hive.box("reminders");

  void getReminders() {
    reminders = _remindersBox.get("REMINDERS")?.cast<int, Reminder>() ?? {};
  }

  void updateReminders() {
    _remindersBox.put("REMINDERS", reminders);
  }

  void deleteReminder(int id) {
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


  void printAll(String str) {
    getReminders();

    print(str);
    print("================");

    reminders.forEach((key, value) {
      print("Key: ($key)");
    });
  }
}