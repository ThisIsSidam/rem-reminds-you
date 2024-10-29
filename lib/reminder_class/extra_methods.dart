import 'package:Rem/reminder_class/reminder.dart';

List<Reminder> sortRemindersByDateTime(List<Reminder> reminderList) {
  reminderList.sort((a, b) => a.dateAndTime.compareTo(b.dateAndTime));
  return reminderList;
}
