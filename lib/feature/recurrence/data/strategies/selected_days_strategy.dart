import 'recurrence_strategy.dart';

class SelectedDaysStrategy implements RecurrenceStrategy {
  SelectedDaysStrategy({required this.weekdays});

  /// Uses DateTime weekday values:
  /// 1 = Monday
  /// 7 = Sunday
  final Set<int> weekdays;

  @override
  bool occursOn(DateTime base, DateTime target) {
    if (target.isBefore(base)) return false;

    return weekdays.contains(target.weekday);
  }

  @override
  DateTime? next(DateTime base) {
    if (weekdays.isEmpty) return null;

    for (int i = 1; i <= 7; i++) {
      final candidate = base.add(Duration(days: i));

      if (weekdays.contains(candidate.weekday)) {
        return candidate;
      }
    }

    return null;
  }
}
