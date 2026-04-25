import 'recurrence_rule.dart';

class DailyRule extends RecurrenceRule {
  const DailyRule();

  factory DailyRule.fromJson(Map<String, dynamic> json) {
    return const DailyRule();
  }

  @override
  int get type => 101;

  @override
  String get name => 'Daily';

  @override
  Map<String, dynamic> toJson() => {'type': type};
}
