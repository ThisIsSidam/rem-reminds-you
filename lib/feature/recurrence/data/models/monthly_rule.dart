import 'recurrence_rule.dart';

class MonthlyRule extends RecurrenceRule {
  const MonthlyRule({super.rescheduleFromDueDate = true});

  factory MonthlyRule.fromJson(Map<String, dynamic> json) {
    return MonthlyRule(
      rescheduleFromDueDate: (json['rescheduleFromDueDate'] as bool?) ?? true,
    );
  }

  @override
  int get type => 1001;

  @override
  String get name => 'Monthly';

  @override
  String get description => 'Repeats monthly';

  MonthlyRule copyWith({bool? rescheduleFromDueDate}) => MonthlyRule(
    rescheduleFromDueDate: rescheduleFromDueDate ?? this.rescheduleFromDueDate,
  );

  @override
  MonthlyRule copyWithReschedule(bool rescheduleFromDueDate) =>
      copyWith(rescheduleFromDueDate: rescheduleFromDueDate);
}
