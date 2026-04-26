import 'recurrence_strategy.dart';

class WeeklyStrategy implements RecurrenceStrategy {
  WeeklyStrategy({this.noOfWeeks = 1});

  final int noOfWeeks;

  int get days => noOfWeeks * 7;

  @override
  bool occursOn(DateTime base, DateTime target) {
    if (target.isBefore(base)) return false;
    final int diff = target.difference(base).inDays;
    return diff >= 0 && diff % days == 0;
  }

  @override
  DateTime next(DateTime base) {
    return base.add(Duration(days: days));
  }
}
