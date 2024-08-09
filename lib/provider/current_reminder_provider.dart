import 'package:Rem/reminder_class/reminder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReminderNotifier extends Notifier<Reminder> {

  @override
  Reminder build() {
    return Reminder(
      dateAndTime: DateTime.now()
    );
  }

  void updateReminder(Reminder newReminder) {
    state = newReminder;
  }
}

final reminderNotifierProvider = NotifierProvider<ReminderNotifier, Reminder>(() {
  return ReminderNotifier();
});