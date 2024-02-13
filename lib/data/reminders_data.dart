import 'package:hive_flutter/hive_flutter.dart';
import 'package:nagger/utils/reminder.dart';

class RemindersData {
  Map<int, Reminder> reminders = {};
  final _remindersBox = Hive.box("reminders");

  void getReminders() {
    reminders = _remindersBox.get("REMINDERS")?.cast<int, Reminder>() ?? {};
  }

  void updateReminders() {
    _remindersBox.put("REMINDERS", reminders);
  }

  // id is made by concatenating title and return value of getDateTimeAsStr
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