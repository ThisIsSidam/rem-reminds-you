import 'recurrence_rule.dart';

class RecurrenceEngine {
  static Duration? nextOccurense({
    required DateTime base,
    required RecurrenceRule rule,
  }) {
    return switch (rule.type) {
      101 => const Duration(days: 1),
      707 => const Duration(days: 7),
      1001 => toNextMonth(base),
      // Includes default '99' and non recognized types
      _ => null,
    };
  }

  static Duration toNextMonth(DateTime date) {
    final int nextMonth = date.month == 12 ? 1 : date.month + 1;
    final int nextYear = date.month == 12 ? date.year + 1 : date.year;

    // Get the last day of the target next month
    final int lastDayOfNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;

    // Use the minimum of current day and last day of next month
    final int adjustedDay =
        date.day <= lastDayOfNextMonth ? date.day : lastDayOfNextMonth;

    final DateTime nextDt = DateTime(
      nextYear,
      nextMonth,
      adjustedDay,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );

    final Duration diff = nextDt.difference(date);
    return diff;
  }
}
