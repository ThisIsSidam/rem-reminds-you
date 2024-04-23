part of 'reminder.dart';

// Used mainly by the background service to check if the notifciations
// should be send or not.

enum ReminderStatus {
  pending, // Time is yet to come, no notifs.
  due, // Time has come, send notifs.
  silenced, // No notif
  done // No notif
}

class RemindersStatusExtension{
  static String getDisplayName(ReminderStatus frequency) {
    switch (frequency) {
      case ReminderStatus.pending:
        return 'None';
      case ReminderStatus.due:
        return 'Daily';
      case ReminderStatus.silenced:
        return 'Weekly';
      case ReminderStatus.done:
        return 'Custom';
    }
  }

  static ReminderStatus fromString(String value) {
    return ReminderStatus.values.firstWhere(
      (frequency) =>
          getDisplayName(frequency).toLowerCase() == value.toLowerCase(),
      orElse: () => ReminderStatus.pending,
    );
  }

  static ReminderStatus fromInt(int value) {
    return ReminderStatus.values[value];
  }

  static int getIndex(ReminderStatus frequency) {
    return frequency.index;
  }
}