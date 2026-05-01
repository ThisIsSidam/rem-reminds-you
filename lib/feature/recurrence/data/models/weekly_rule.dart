import 'recurrence_rule.dart';

class WeeklyRule extends RecurrenceRule {
  const WeeklyRule({this.noOfWeeks = 1, super.rescheduleFromDueDate = true});

  factory WeeklyRule.fromJson(Map<String, dynamic> json) {
    return WeeklyRule(
      noOfWeeks: json['noOfWeeks'] as int? ?? 1,
      rescheduleFromDueDate: (json['rescheduleFromDueDate'] as bool?) ?? true,
    );
  }

  @override
  int get type => 707;

  @override
  String get name => 'Weekly';

  @override
  String get description => switch (noOfWeeks) {
    1 => 'Repeats every week',
    _ => 'Repeats every $noOfWeeks weeks',
  };

  final int noOfWeeks;

  WeeklyRule copyWith({int? noOfWeeks, bool? rescheduleFromDueDate}) =>
      WeeklyRule(
        noOfWeeks: noOfWeeks ?? this.noOfWeeks,
        rescheduleFromDueDate:
            rescheduleFromDueDate ?? this.rescheduleFromDueDate,
      );

  @override
  WeeklyRule copyWithReschedule(bool rescheduleFromDueDate) =>
      copyWith(rescheduleFromDueDate: rescheduleFromDueDate);

  @override
  Map<String, dynamic> toJson() => {'noOfWeeks': noOfWeeks, ...super.toJson()};
}
