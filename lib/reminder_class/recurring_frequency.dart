part of 'reminder.dart';

enum RecurringFrequency {
  none,
  daily,
  weekly,
  custom
}

class RecurringFrequencyExtension{
  static String getDisplayName(RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.none:
        return 'None';
      case RecurringFrequency.daily:
        return 'Daily';
      case RecurringFrequency.weekly:
        return 'Weekly';
      case RecurringFrequency.custom:
        return 'Custom';
    }
  }

  static RecurringFrequency fromString(String value) {
    return RecurringFrequency.values.firstWhere(
      (frequency) =>
          getDisplayName(frequency).toLowerCase() == value.toLowerCase(),
      orElse: () => RecurringFrequency.none,
    );
  }

  static RecurringFrequency fromInt(int value) {
    return RecurringFrequency.values[value];
  }

  static int getIndex(RecurringFrequency frequency) {
    return frequency.index;
  }
}