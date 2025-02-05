import 'package:hive_ce_flutter/hive_flutter.dart';

part 'recurring_interval.g.dart';

@HiveType(typeId: 2)
enum RecurringInterval {
  @HiveField(0)
  none,
  @HiveField(1)
  daily,
  @HiveField(2)
  weekly,
  @HiveField(3)
  weekdays,
  @HiveField(4)
  weekends,
  @HiveField(5)
  monthly;

  @override
  String toString() {
    switch (this) {
      case none:
        return 'None';
      case daily:
        return 'Daily';
      case weekly:
        return 'Weekly';
      case weekdays:
        return 'Weekdays';
      case weekends:
        return 'Weekends';
      case monthly:
        return 'Monthly';
    }
  }

  static RecurringInterval fromString(String value) {
    return RecurringInterval.values.firstWhere(
      (interval) => interval.toString().toLowerCase() == value.toLowerCase(),
      orElse: () => RecurringInterval.none,
    );
  }

  static RecurringInterval fromIndex(int value) {
    return RecurringInterval.values[value];
  }

  Duration? getRecurringIncrementDuration(DateTime dt) {
    switch (this) {
      case daily:
        return const Duration(days: 1);
      case weekly:
        return const Duration(days: 7);
      case weekdays:
        return _getDurationForNextWeekday(dt);
      case weekends:
        return _getDurationForNextWeekend(dt);
      case monthly:
        return _getDurationForNextMonth(dt);
      case none:
        return null;
    }
  }

  Duration? getRecurringDecrementDuration(DateTime dt) {
    switch (this) {
      case daily:
        return const Duration(days: 1);
      case weekly:
        return const Duration(days: 7);
      case weekdays:
        return _getDurationForPreviousWeekday(dt);
      case weekends:
        return _getDurationForPreviousWeekend(dt);
      case monthly:
        return _getDurationForPreviousMonth(dt);
      case none:
        return null;
    }
  }
}

Duration _getDurationForNextWeekday(DateTime dt) {
  int daysToAdd = 1;
  if (dt.weekday == DateTime.friday) {
    daysToAdd = 3;
  } else if (dt.weekday == DateTime.saturday) {
    daysToAdd = 2;
  }

  return Duration(days: daysToAdd);
}

Duration _getDurationForNextWeekend(DateTime dt) {
  int daysToAdd = 1;

  if (dt.weekday == DateTime.friday) {
    daysToAdd = 1;
  } else if (dt.weekday == DateTime.saturday) {
    daysToAdd = 1;
  } else if (dt.weekday == DateTime.sunday) {
    daysToAdd = 6;
  } else {
    daysToAdd = DateTime.saturday - dt.weekday;
  }

  return Duration(days: daysToAdd);
}

Duration _getDurationForNextMonth(DateTime dt) {
  final updatedDateTime = dt.copyWith(
    month: dt.month + 1,
  );

  return updatedDateTime.difference(dt);
}

Duration _getDurationForPreviousWeekday(DateTime dt) {
  int daysToSubtract = 1;
  if (dt.weekday == DateTime.monday) {
    daysToSubtract = 3;
  } else if (dt.weekday == DateTime.sunday) {
    daysToSubtract = 2;
  }

  return Duration(days: daysToSubtract);
}

Duration _getDurationForPreviousWeekend(DateTime dt) {
  int daysToSubtract = 1;

  if (dt.weekday == DateTime.monday) {
    daysToSubtract = 1;
  } else if (dt.weekday == DateTime.sunday) {
    daysToSubtract = 1;
  } else if (dt.weekday == DateTime.saturday) {
    daysToSubtract = 6;
  } else {
    daysToSubtract = dt.weekday - DateTime.saturday;
  }

  return Duration(days: daysToSubtract);
}

Duration _getDurationForPreviousMonth(DateTime dt) {
  final updatedDateTime = dt.copyWith(
    month: dt.month - 1,
  );

  return dt.difference(updatedDateTime);
}
