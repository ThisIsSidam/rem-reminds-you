import 'package:Rem/reminder_class/reminder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReminderNotifier extends StateNotifier<Reminder> {

  ReminderNotifier() : super(Reminder(dateAndTime: DateTime.now()));

  void updateReminder(Reminder newReminder) {
    print("Value Updated");
    state = newReminder.deepCopyReminder();
  }
}

final reminderNotifierProvider = StateNotifierProvider<ReminderNotifier, Reminder>((ref
) {
  return ReminderNotifier();
});