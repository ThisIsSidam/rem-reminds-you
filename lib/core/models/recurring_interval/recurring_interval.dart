// Using type codes instead of string so we can
// change constructor names without hindering type names
// Otherwise, if I wanted to change 'weekly' to something
// else, I would want to also change the type string
// 'weekly', hence ints instead.
import 'dart:convert';

class RecurringInterval {
  RecurringInterval() : type = 99;
  RecurringInterval.daily() : type = 101;
  RecurringInterval.weekly() : type = 707;

  factory RecurringInterval.fromJson(Map<String, dynamic> json) {
    final int type = json['type'] as int? ?? 0;
    switch (type) {
      case 99:
        return RecurringInterval();
      case 101:
        return RecurringInterval.daily();
      case 707:
        return RecurringInterval.weekly();
      default:
        return RecurringInterval();
    }
  }

  factory RecurringInterval.fromString(String encoded) {
    return RecurringInterval.fromJson(
      jsonDecode(encoded) as Map<String, dynamic>,
    );
  }

  int type;

  Duration? toNext() {
    switch (type) {
      case 99:
        return null;
      case 101:
        return const Duration(days: 1);
      case 707:
        return const Duration(days: 7);
      default:
        return null;
    }
  }

  Duration? toPrevious() {
    switch (type) {
      case 99:
        return null;
      case 101:
        return const Duration(days: 1);
      case 707:
        return const Duration(days: 7);
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson);
  }
}
