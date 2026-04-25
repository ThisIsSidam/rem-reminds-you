import 'recurrence_rule.dart';

class NoRecurrenceRule extends RecurrenceRule {
  const NoRecurrenceRule();

  @override
  int get type => 99;

  @override
  String get name => 'None';

  @override
  Map<String, dynamic> toJson() => {'type': type};
}
