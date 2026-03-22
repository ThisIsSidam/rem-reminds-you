import 'recurrence_strategy.dart';

class MonthlyStrategy implements RecurrenceStrategy {
  MonthlyStrategy();

  @override
  bool occursOn(DateTime base, DateTime target) {
    if (target.isBefore(base)) return false;

    final int monthDiff =
        (target.year - base.year) * 12 + (target.month - base.month);

    if (monthDiff < 0) return false;

    // Get target month's last day
    final int lastDay = DateTime(target.year, target.month + 1, 0).day;

    // If the target month has that date, then pick that date for check,
    // otherwise take last date.
    final int expectedDay = base.day <= lastDay ? base.day : lastDay;

    return target.day == expectedDay;
  }

  @override
  DateTime next(DateTime base) {
    final int nextMonth = base.month == 12 ? 1 : base.month + 1;
    final int nextYear = base.month == 12 ? base.year + 1 : base.year;

    // Get the last day of the target next month
    final int lastDayOfNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;

    // Use the minimum of current day and last day of next month
    final int adjustedDay =
        base.day <= lastDayOfNextMonth ? base.day : lastDayOfNextMonth;

    return DateTime(
      nextYear,
      nextMonth,
      adjustedDay,
      base.hour,
      base.minute,
      base.second,
      base.millisecond,
      base.microsecond,
    );
  }
}
