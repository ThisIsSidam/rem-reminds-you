import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:random_datetime/random_datetime.dart';
import 'package:random_datetime/random_dt_options.dart';

import '../../../feature/settings/presentation/providers/settings_provider.dart';
import '../reminder_model/reminder_model.dart';

part 'no_rush_reminders.g.dart';

@HiveType(typeId: 3)
class NoRushRemindersModel implements ReminderModel {
  NoRushRemindersModel({
    required this.id,
    required this.title,
    required this.autoSnoozeInterval,
    required this.dateTime,
  }) : preParsedTitle = title;

  @override
  @HiveField(0)
  int id;
  @override
  @HiveField(1)
  String title;
  @override
  @HiveField(2)
  DateTime dateTime;
  @override
  @HiveField(3)
  String preParsedTitle;
  @override
  @HiveField(4)
  Duration? autoSnoozeInterval;

  @override
  ReminderModel copyWith({
    int? id,
    String? title,
    DateTime? dateTime,
    String? preParsedTitle,
    Duration? autoSnoozeInterval,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      preParsedTitle: preParsedTitle ?? this.preParsedTitle,
      autoSnoozeInterval: autoSnoozeInterval ?? this.autoSnoozeInterval,
    );
  }

  @override
  Map<String, String?> toJson() {
    return <String, String?>{
      'id': id.toString(),
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'PreParsedTitle': preParsedTitle,
      'autoSnoozeInterval': autoSnoozeInterval?.inMilliseconds.toString(),
    };
  }

  // Will use fromJson and toJson methods of ReminderModel as the attributes
  // are same

  /// Generate DateTime for this new noRush reminder.
  /// Is used in the provider, when creating the new noRush reminder
  static DateTime generateRandomFutureTime() {
    final UserSettingsNotifier settings = UserSettingsNotifier();
    final TimeOfDay startTime = settings.quietHoursStartTime;
    final TimeOfDay endTime = settings.quietHoursEndTime;

    final DateTime now = DateTime.now();
    final DateTime startDate = now.add(const Duration(days: 3));
    final DateTime endDate = now.add(const Duration(days: 14));

    final RandomDateTime randomTime = RandomDateTime(
      options: RandomDTOptions.withRange(
        yearRange: TimeRange(start: startDate.year, end: endDate.year),
        monthRange: TimeRange(start: startDate.month, end: endDate.month),
        dayRange: TimeRange(start: startDate.day, end: endDate.day),

        // start is end and vice versa because time range is of quiet hours
        hourRange: TimeRange(start: endTime.hour, end: startTime.hour),
        minuteRange: TimeRange(start: endTime.minute, end: startTime.minute),
        secondRange: const TimeRange(start: 0, end: 0),
        millisecondRange: const TimeRange(start: 0, end: 0),
        microsecondRange: const TimeRange(start: 0, end: 0),
      ),
    );

    return randomTime.random();
  }
}
