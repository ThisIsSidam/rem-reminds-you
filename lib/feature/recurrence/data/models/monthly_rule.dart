import 'recurrence_rule.dart';

class MonthlyRule extends RecurrenceRule {
  const MonthlyRule();

  factory MonthlyRule.fromJson(Map<String, dynamic> json) {
    return const MonthlyRule();
  }

  @override
  int get type => 1001;

  @override
  String get name => 'Monthly';

  @override
  Map<String, dynamic> toJson() => {'type': type};
}
