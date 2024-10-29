import 'package:Rem/reminder_class/reminder.dart';
import 'package:hive_flutter/hive_flutter.dart';

mixin Recur {
  /// The time in-between the reminder notifications.
  @HiveField(5)
  int mixinRecurringInterval = 0;

  /// The time for the next recurring reminder
  @HiveField(6)
  DateTime baseDateTime = DateTime.now();

  void initRecurringInterval(RecurringInterval? interval) {
    mixinRecurringInterval = (interval ?? RecurringInterval.none).index;
  }

  RecurringInterval get recurringInterval {
    return RecurringInterval.fromInt(mixinRecurringInterval);
  }

  void set recurringInterval(RecurringInterval interval) {
    mixinRecurringInterval = RecurringInterval.getIndex(interval);
  }

  String getRecurringIntervalAsString() {
    return RecurringInterval.fromInt(mixinRecurringInterval).toString();
  }

  Duration? getRecurIncrementDuration() {
    if (mixinRecurringInterval == RecurringInterval.none) {
      return null;
    }

    final recurringInterval = RecurringInterval.fromInt(mixinRecurringInterval);

    if (recurringInterval == RecurringInterval.daily) {
      return Duration(days: 1);
    } else if (recurringInterval == RecurringInterval.weekly) {
      return Duration(days: 7);
    } else {
      return null;
    }
  }
}
