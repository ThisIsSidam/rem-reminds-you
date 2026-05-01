import '../data/models/daily_rule.dart';
import '../data/models/monthly_rule.dart';
import '../data/models/recurrence_rule.dart';
import '../data/models/selected_days_rule.dart';
import '../data/models/weekly_rule.dart';
import '../data/strategies/daily_strategy.dart';
import '../data/strategies/monthly_strategy.dart';
import '../data/strategies/no_recurrence_strategy.dart';
import '../data/strategies/recurrence_strategy.dart';
import '../data/strategies/selected_days_strategy.dart';
import '../data/strategies/weekly_strategy.dart';

class RecurrenceFactory {
  static RecurrenceStrategy fromRule(RecurrenceRule rule) {
    return switch (rule) {
      DailyRule() => DailyStrategy(),
      WeeklyRule(:final noOfWeeks) => WeeklyStrategy(noOfWeeks: noOfWeeks),
      SelectedDaysRule(:final weekdays) => SelectedDaysStrategy(
        weekdays: weekdays,
      ),
      MonthlyRule() => MonthlyStrategy(),
      _ => NoRecurrenceStrategy(),
    };
  }
}
