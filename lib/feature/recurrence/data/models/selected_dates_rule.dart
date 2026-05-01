import 'dart:convert';

import 'recurrence_rule.dart';

class SelectedDatesRule extends RecurrenceRule {
  const SelectedDatesRule({
    required this.daysOfMonth,
    super.rescheduleFromDueDate = true,
  });

  factory SelectedDatesRule.fromJson(Map<String, dynamic> json) {
    return SelectedDatesRule(
      daysOfMonth: Set<int>.from(json['daysOfMonth'] as List? ?? []),
      rescheduleFromDueDate: (json['rescheduleFromDueDate'] as bool?) ?? true,
    );
  }

  final Set<int> daysOfMonth;

  static Map<int, String> dates = {for (int i = 1; i <= 31; i++) i: '$i'};

  @override
  int get type => 1701;

  @override
  String get name => 'Specific Dates';

  @override
  String get description {
    if (daysOfMonth.isEmpty) {
      return 'No dates selected';
    }

    final sorted = daysOfMonth.toList()..sort();

    return 'Repeats on ${sorted.join(', ')}';
  }

  SelectedDatesRule copyWith({
    Set<int>? daysOfMonth,
    bool? rescheduleFromDueDate,
  }) {
    return SelectedDatesRule(
      daysOfMonth: daysOfMonth ?? this.daysOfMonth,
      rescheduleFromDueDate:
          rescheduleFromDueDate ?? this.rescheduleFromDueDate,
    );
  }

  @override
  SelectedDatesRule copyWithReschedule(bool rescheduleFromDueDate) =>
      copyWith(rescheduleFromDueDate: rescheduleFromDueDate);

  @override
  Map<String, dynamic> toJson() => {
    'daysOfMonth': daysOfMonth.toList(),
    ...super.toJson(),
  };

  @override
  String toString() => jsonEncode(toJson());
}
