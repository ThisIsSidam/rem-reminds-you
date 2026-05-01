import 'dart:convert';

import 'daily_rule.dart';
import 'monthly_rule.dart';
import 'no_recurrence_rule.dart';
import 'selected_dates_rule.dart';
import 'selected_days_rule.dart';
import 'weekly_rule.dart';

abstract class RecurrenceRule {
  const RecurrenceRule({this.rescheduleFromDueDate = true});

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    final int type = json['type'] as int? ?? 0;

    return switch (type) {
      101 => DailyRule.fromJson(json),
      707 => WeeklyRule.fromJson(json),
      1501 => SelectedDaysRule.fromJson(json),
      1701 => SelectedDatesRule.fromJson(json),
      1001 => MonthlyRule.fromJson(json),
      _ => const NoRecurrenceRule(),
    };
  }

  factory RecurrenceRule.fromString(String encoded) {
    return RecurrenceRule.fromJson(jsonDecode(encoded) as Map<String, dynamic>);
  }

  /// Type of the [RecurrenceRule]. Same for all instances of a type.
  int get type;

  /// Name of the [RecurrenceRule]. Same for all instances of a type.
  String get name;

  /// Description of the [RecurrenceRule]. Uses a rule's specific fields to
  /// describe when the reminder would recurr.
  String get description;

  /// A boolean specifying whether the reschedule date would be generated based
  /// on the due date or the postponed (if-postponed) date.
  final bool rescheduleFromDueDate;

  RecurrenceRule copyWithReschedule(bool rescheduleFromDueDate);

  Map<String, dynamic> toJson() => {
    'type': type,
    'rescheduleFromDueDate': rescheduleFromDueDate,
  };

  @override
  String toString() => jsonEncode(toJson());

  bool get isNone => switch (this) {
    NoRecurrenceRule() => true,
    _ => false,
  };
}
