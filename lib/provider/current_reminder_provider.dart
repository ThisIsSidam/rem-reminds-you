import 'package:Rem/reminder_class/reminder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReminderNotifier extends StateNotifier<Reminder> {
  ReminderNotifier() : super(Reminder(dateAndTime: DateTime.now()));

  void updateReminder(Reminder newReminder) {
    state = newReminder.deepCopyReminder();
  }

  void resetReminder() {
    state = Reminder(dateAndTime: DateTime.now());
  }
}

final reminderNotifierProvider =
    StateNotifierProvider<ReminderNotifier, Reminder>((ref) {
  return ReminderNotifier();
});
