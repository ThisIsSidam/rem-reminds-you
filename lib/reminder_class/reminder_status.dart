part of 'reminder.dart';

// Used mainly by the background service to check if the notifciations
// should be send or not.

enum ReminderStatus {
  active, // Notif
  done, // No notif
  archived
}

class RemindersStatusExtension{
  static String getDisplayName(ReminderStatus frequency) {
    switch (frequency) {
      case ReminderStatus.active:
        return 'active';
      case ReminderStatus.done:
        return 'done';
      case ReminderStatus.archived:
        return 'archived';
      default:
        return 'unknown';
    }
  }

  static ReminderStatus fromString(String value) {
    return ReminderStatus.values.firstWhere(
      (frequency) =>
          getDisplayName(frequency).toLowerCase() == value.toLowerCase(),
      orElse: () => ReminderStatus.done,
    );
  }

  static ReminderStatus fromInt(int value) {
    return ReminderStatus.values[value];
  }

  static int getIndex(ReminderStatus frequency) {
    return frequency.index;
  }
}
