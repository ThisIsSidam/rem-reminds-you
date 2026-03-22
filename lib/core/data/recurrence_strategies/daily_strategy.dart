import 'recurrence_strategy.dart';

class DailyStrategy implements RecurrenceStrategy {
  DailyStrategy();

  @override
  bool occursOn(DateTime base, DateTime target) {
    // Target time is NOT in the past.. can be same time, or in future
    return !target.isBefore(base);
  }

  @override
  DateTime next(DateTime base) {
    return base.add(const Duration(days: 1));
  }
}
