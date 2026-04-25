import 'recurrence_rule.dart';

class WeeklyRule extends RecurrenceRule {
  const WeeklyRule();

  factory WeeklyRule.fromJson(Map<String, dynamic> json) {
    return const WeeklyRule();
  }

  @override
  int get type => 707;

  @override
  String get name => 'Weekly';

  @override
  Map<String, dynamic> toJson() => {'type': type};
}
