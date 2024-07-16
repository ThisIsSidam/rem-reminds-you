part of 'reminder.dart';

enum RecurringInterval {
  none,
  daily,
  weekly,
  custom
}

class RecurringIntervalExtension{
  static String getDisplayName(RecurringInterval interval) {
    switch (interval) {
      case RecurringInterval.none:
        return 'None';
      case RecurringInterval.daily:
        return 'Daily';
      case RecurringInterval.weekly:
        return 'Weekly';
      case RecurringInterval.custom:
        return 'Custom';
    }
  }

  static RecurringInterval fromString(String value) {
    return RecurringInterval.values.firstWhere(
      (interval) =>
          getDisplayName(interval).toLowerCase() == value.toLowerCase(),
      orElse: () => RecurringInterval.none,
    );
  }

  static RecurringInterval fromInt(int value) {
    return RecurringInterval.values[value];
  }

  static int getIndex(RecurringInterval interval) {
    return interval.index;
  }
}