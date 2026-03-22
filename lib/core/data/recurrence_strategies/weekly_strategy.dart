import 'recurrence_strategy.dart';

class WeeklyStrategy implements RecurrenceStrategy {
  WeeklyStrategy();

  @override
  bool occursOn(DateTime base, DateTime target) {
    if (target.isBefore(base)) return false;
    final int diff = target.difference(base).inDays;
    return diff >= 0 && diff % 7 == 0;
  }

  @override
  DateTime next(DateTime base) {
    return base.add(const Duration(days: 7));
  }
}
