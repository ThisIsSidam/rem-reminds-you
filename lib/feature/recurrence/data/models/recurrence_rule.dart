import 'dart:convert';

import 'daily_rule.dart';
import 'monthly_rule.dart';
import 'no_recurrence_rule.dart';
import 'weekly_rule.dart';

abstract class RecurrenceRule {
  const RecurrenceRule();

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    final int type = json['type'] as int? ?? 0;

    return switch (type) {
      101 => DailyRule.fromJson(json),
      707 => WeeklyRule.fromJson(json),
      1001 => MonthlyRule.fromJson(json),
      _ => const NoRecurrenceRule(),
    };
  }

  factory RecurrenceRule.fromString(String encoded) {
    return RecurrenceRule.fromJson(jsonDecode(encoded) as Map<String, dynamic>);
  }

  int get type;

  String get name;

  String get description;

  Map<String, dynamic> toJson();

  @override
  String toString() => jsonEncode(toJson());

  bool get isNone => switch (this) {
    NoRecurrenceRule() => true,
    _ => false,
  };
}
