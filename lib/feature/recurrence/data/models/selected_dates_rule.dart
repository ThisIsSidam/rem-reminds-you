import 'dart:convert';

import 'recurrence_rule.dart';

class SelectedDatesRule extends RecurrenceRule {
  const SelectedDatesRule({required this.daysOfMonth});

  factory SelectedDatesRule.fromJson(Map<String, dynamic> json) {
    return SelectedDatesRule(
      daysOfMonth: Set<int>.from(json['daysOfMonth'] as List? ?? []),
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

  SelectedDatesRule copyWith({Set<int>? daysOfMonth}) {
    return SelectedDatesRule(daysOfMonth: daysOfMonth ?? this.daysOfMonth);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'daysOfMonth': daysOfMonth.toList(),
  };

  @override
  String toString() => jsonEncode(toJson());
}
