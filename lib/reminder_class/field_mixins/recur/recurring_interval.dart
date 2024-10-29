part of '../../reminder.dart';

enum RecurringInterval {
  none,
  daily,
  weekly,
  custom;

  @override
  String toString() {
    switch (this) {
      case none:
        return 'None';
      case daily:
        return 'Daily';
      case weekly:
        return 'Weekly';
      case custom:
        return 'Custom';
    }
  }

  static RecurringInterval fromString(String value) {
    return RecurringInterval.values.firstWhere(
      (interval) => interval.toString().toLowerCase() == value.toLowerCase(),
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
