import 'recurrence_strategy.dart';

class SelectedDatesStrategy implements RecurrenceStrategy {
  SelectedDatesStrategy({required this.daysOfMonth});

  final Set<int> daysOfMonth;

  @override
  bool occursOn(DateTime base, DateTime target) {
    if (target.isBefore(base)) {
      return false;
    }

    return daysOfMonth.contains(target.day);
  }

  @override
  DateTime? next(DateTime base) {
    if (daysOfMonth.isEmpty) {
      return null;
    }

    DateTime candidate = base;

    for (int i = 1; i <= 366; i++) {
      candidate = base.add(Duration(days: i));

      if (daysOfMonth.contains(candidate.day)) {
        return candidate;
      }
    }

    return null;
  }
}
