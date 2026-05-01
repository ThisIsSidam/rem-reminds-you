import 'recurrence_rule.dart';

class DailyRule extends RecurrenceRule {
  const DailyRule({super.rescheduleFromDueDate = true});

  factory DailyRule.fromJson(Map<String, dynamic> json) {
    return DailyRule(
      rescheduleFromDueDate: (json['rescheduleFromDueDate'] as bool?) ?? true,
    );
  }

  @override
  int get type => 101;

  @override
  String get name => 'Daily';

  @override
  String get description => 'Repeats daily';

  DailyRule copyWith({bool? rescheduleFromDueDate}) => DailyRule(
    rescheduleFromDueDate: rescheduleFromDueDate ?? this.rescheduleFromDueDate,
  );

  @override
  DailyRule copyWithReschedule(bool rescheduleFromDueDate) =>
      copyWith(rescheduleFromDueDate: rescheduleFromDueDate);
}
