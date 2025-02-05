import 'package:Rem/feature/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:random_datetime/random_datetime.dart';
import 'package:random_datetime/random_dt_options.dart';

import '../reminder_model/reminder_model.dart';

part 'no_rush_reminders.g.dart';

@HiveType(typeId: 3)
class NoRushRemindersModel extends ReminderModel {
  NoRushRemindersModel(
      {required super.id,
      required super.title,
      required super.autoSnoozeInterval,
      required super.dateTime})
      : super(
          PreParsedTitle: title,
        );

  // Will use fromJson and toJson methods of ReminderModel as the attributes
  // are same

  /// Generate DateTime for this new noRush reminder.
  /// Is used in the provider, when creating the new noRush reminder
  static DateTime generateRandomFutureTime() {
    final UserSettingsNotifier settings = UserSettingsNotifier();
    final TimeOfDay startTime = settings.quietHoursStartTime;
    final TimeOfDay endTime = settings.quietHoursEndTime;

    final DateTime now = DateTime.now();
    final DateTime startDate = now.add(Duration(days: 3));
    final DateTime endDate = now.add(Duration(days: 14));

    final RandomDateTime randomTime = RandomDateTime(
      options: RandomDTOptions.withRange(
        yearRange: TimeRange(start: startDate.year, end: endDate.year),
        monthRange: TimeRange(start: startDate.month, end: endDate.month),
        dayRange: TimeRange(start: startDate.day, end: endDate.day),

        // start is end and vice versa because time range is of quiet hours
        hourRange: TimeRange(start: endTime.hour, end: startTime.hour),
        minuteRange: TimeRange(start: endTime.minute, end: startTime.minute),
        secondRange: TimeRange(start: 0, end: 0),
        millisecondRange: TimeRange(start: 0, end: 0),
        microsecondRange: TimeRange(start: 0, end: 0),
      ),
    );

    return randomTime.random();
  }
}
