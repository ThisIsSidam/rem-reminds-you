import 'recurrence_rule.dart';

class WeeklyRule extends RecurrenceRule {
  const WeeklyRule({this.noOfWeeks = 1});

  factory WeeklyRule.fromJson(Map<String, dynamic> json) {
    return WeeklyRule(noOfWeeks: json['noOfWeeks'] as int? ?? 1);
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

  WeeklyRule copyWith({int? noOfWeeks}) =>
      WeeklyRule(noOfWeeks: noOfWeeks ?? this.noOfWeeks);

  @override
  Map<String, dynamic> toJson() => {'type': type, 'noOfWeeks': noOfWeeks};
}
