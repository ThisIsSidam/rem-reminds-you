part of 'reminder.dart';

enum RepeatInterval {
  none,
  daily,
  weekly,
  custom
}

class RepeatIntervalExtension{
  static String getDisplayName(RepeatInterval interval) {
    switch (interval) {
      case RepeatInterval.none:
        return 'None';
      case RepeatInterval.daily:
        return 'Daily';
      case RepeatInterval.weekly:
        return 'Weekly';
      case RepeatInterval.custom:
        return 'Custom';
    }
  }

  static RepeatInterval fromString(String value) {
    return RepeatInterval.values.firstWhere(
      (interval) =>
          getDisplayName(interval).toLowerCase() == value.toLowerCase(),
      orElse: () => RepeatInterval.none,
    );
  }

  static RepeatInterval fromInt(int value) {
    return RepeatInterval.values[value];
  }

  static int getIndex(RepeatInterval interval) {
    return interval.index;
  }
}