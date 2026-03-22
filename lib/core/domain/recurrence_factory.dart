import '../data/models/recurrence_rule.dart';
import '../data/recurrence_strategies/daily_strategy.dart';
import '../data/recurrence_strategies/monthly_strategy.dart';
import '../data/recurrence_strategies/no_recurrence_strategy.dart';
import '../data/recurrence_strategies/recurrence_strategy.dart';
import '../data/recurrence_strategies/weekly_strategy.dart';

class RecurrenceFactory {
  static RecurrenceStrategy fromRule(RecurrenceRule rule) {
    return switch (rule.type) {
      101 => DailyStrategy(),
      707 => WeeklyStrategy(),
      1001 => MonthlyStrategy(),
      _ => NoRecurrenceStrategy(),
    };
  }
}
