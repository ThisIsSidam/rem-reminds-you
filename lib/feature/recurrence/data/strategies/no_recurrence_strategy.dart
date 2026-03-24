import 'recurrence_strategy.dart';

class NoRecurrenceStrategy implements RecurrenceStrategy {
  @override
  bool occursOn(DateTime base, DateTime target) {
    // Occurs on same date or not. Only date matters here.s
    return base.year == target.year &&
        base.month == target.month &&
        base.day == target.day;
  }

  @override
  DateTime? next(_) => null; // No next timings
}
