import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/logger/global_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SheetReminderNotifier extends StateNotifier<Reminder> {
  SheetReminderNotifier() : super(Reminder(dateAndTime: DateTime.now())) {
    gLogger.i('SheetReminderNotifier initialized');
  }

  @override
  void dispose() {
    gLogger.i('ReminderNotifier disposed');
    super.dispose();
  }

  void updateReminder(Reminder newReminder) {
    state = newReminder.deepCopyReminder();
  }

  void resetReminder() {
    state = Reminder(dateAndTime: DateTime.now());
  }
}

final reminderNotifierProvider =
    StateNotifierProvider<SheetReminderNotifier, Reminder>((ref) {
  return SheetReminderNotifier();
});
