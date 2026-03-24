import '../../extensions/datetime_ext.dart';
import 'recurrence_strategy.dart';

class DailyStrategy implements RecurrenceStrategy {
  DailyStrategy();

  @override
  bool occursOn(DateTime base, DateTime target) {
    // Target time is NOT in the past.. can be same time, or in future
    return base.isSameDayAs(target) || target.isAfter(base);
  }

  @override
  DateTime next(DateTime base) {
    return base.add(const Duration(days: 1));
  }
}
