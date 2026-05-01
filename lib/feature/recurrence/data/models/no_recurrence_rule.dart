import 'recurrence_rule.dart';

class NoRecurrenceRule extends RecurrenceRule {
  const NoRecurrenceRule();

  @override
  int get type => 99;

  @override
  String get name => 'None';

  @override
  String get description => 'Never repeats';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  RecurrenceRule copyWithReschedule(bool rescheduleFromDueDate) =>
      const NoRecurrenceRule();
}
