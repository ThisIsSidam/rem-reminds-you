import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
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
    if (interval == null) {
      final recurringIntervalString =
          UserDB.getSetting(SettingOption.RecurringIntervalFieldValue);
      interval = RecurringIntervalExtension.fromString(recurringIntervalString);
    }
    mixinRecurringInterval = RecurringIntervalExtension.getIndex(interval);
  }

  RecurringInterval get recurringInterval {
    return RecurringIntervalExtension.fromInt(mixinRecurringInterval);
  }

  void set recurringInterval(RecurringInterval interval) {
    mixinRecurringInterval = RecurringIntervalExtension.getIndex(interval);
  }

  String getRecurringIntervalAsString() {
    return RecurringIntervalExtension.getDisplayName(
        RecurringIntervalExtension.fromInt(mixinRecurringInterval));
  }

  Duration? getRecurIncrementDuration() {
    if (mixinRecurringInterval == RecurringInterval.none) {
      return null;
    }

    final recurringInterval =
        RecurringIntervalExtension.fromInt(mixinRecurringInterval);

    if (recurringInterval == RecurringInterval.daily) {
      return Duration(days: 1);
    } else if (recurringInterval == RecurringInterval.weekly) {
      return Duration(days: 7);
    } else {
      return null;
    }
  }
}
