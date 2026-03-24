// Using type codes instead of string so we can
// change constructor names without hindering type names
// Otherwise, if I wanted to change 'weekly' to something
// else, I would want to also change the type string
// 'weekly', hence ints instead.
import 'dart:convert';

class RecurrenceRule {
  RecurrenceRule() : type = 99;
  RecurrenceRule.daily() : type = 101;
  RecurrenceRule.weekly() : type = 707;
  RecurrenceRule.monthly() : type = 1001;

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    final int type = json['type'] as int? ?? 0;
    return switch (type) {
      101 => RecurrenceRule.daily(),
      707 => RecurrenceRule.weekly(),
      1001 => RecurrenceRule.monthly(),
      // Includes default '99' and non recognized types
      _ => RecurrenceRule(),
    };
  }

  factory RecurrenceRule.fromString(String encoded) {
    return RecurrenceRule.fromJson(jsonDecode(encoded) as Map<String, dynamic>);
  }

  int type;

  bool get isNone => type == 99;
  bool get isDaily => type == 101;
  bool get isWeekly => type == 707;
  bool get isMonthly => type == 1001;

  String get name {
    return switch (type) {
      101 => 'Daily',
      707 => 'Weekly',
      1001 => 'Monthly',

      // Includes default '99' and non recognized types
      _ => 'None',
    };
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'type': type};

  @override
  String toString() => jsonEncode(toJson());
}
