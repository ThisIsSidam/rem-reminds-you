// Using type codes instead of string so we can
// change constructor names without hindering type names
// Otherwise, if I wanted to change 'weekly' to something
// else, I would want to also change the type string
// 'weekly', hence ints instead.
import 'dart:convert';

class RecurringInterval {
  RecurringInterval() : type = 99;
  RecurringInterval.daily() : type = 101;
  RecurringInterval.weekly() : type = 707;
  RecurringInterval.monthly() : type = 1001;

  factory RecurringInterval.fromJson(Map<String, dynamic> json) {
    final int type = json['type'] as int? ?? 0;
    switch (type) {
      case 99:
        return RecurringInterval();
      case 101:
        return RecurringInterval.daily();
      case 707:
        return RecurringInterval.weekly();
      case 1001:
        return RecurringInterval.monthly();
      default:
        return RecurringInterval();
    }
  }

  factory RecurringInterval.fromString(String encoded) {
    return RecurringInterval.fromJson(
      jsonDecode(encoded) as Map<String, dynamic>,
    );
  }

  int type;

  bool get isNone => type == 99;
  bool get isDaily => type == 101;
  bool get isWeekly => type == 707;
  bool get isMonthly => type == 1001;

  Duration? toNext(DateTime dateTime) {
    switch (type) {
      case 99:
        return null;
      case 101:
        return const Duration(days: 1);
      case 707:
        return const Duration(days: 7);
      case 1001:
        return toNextMonth(dateTime);
      default:
        return null;
    }
  }

  String get name {
    switch (type) {
      case 99:
        return 'none';
      case 101:
        return 'daily';
      case 707:
        return 'weekly';
      case 1001:
        return 'monthly';
      default:
        return 'none';
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  Duration toNextMonth(DateTime date) {
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
