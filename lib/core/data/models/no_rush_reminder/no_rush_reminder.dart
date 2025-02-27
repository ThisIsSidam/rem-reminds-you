import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_datetime/random_datetime.dart';
import 'package:random_datetime/random_dt_options.dart';

import '../../../../feature/settings/presentation/providers/settings_provider.dart';
import '../../entities/no_rush_entitiy/no_rush_entity.dart';
import '../reminder_base/reminder_base.dart';

class NoRushReminderModel implements ReminderBase {
  NoRushReminderModel({
    required this.id,
    required this.title,
    required this.autoSnoozeInterval,
    required this.dateTime,
  });

  @override
  int id;
  @override
  String title;
  @override
  DateTime dateTime;
  Duration autoSnoozeInterval;

  NoRushReminderModel copyWith({
    int? id,
    String? title,
    DateTime? dateTime,
    Duration? autoSnoozeInterval,
  }) {
    return NoRushReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      autoSnoozeInterval: autoSnoozeInterval ?? this.autoSnoozeInterval,
    );
  }

  Map<String, String?> toJson() {
    return <String, String?>{
      'id': id.toString(),
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'autoSnoozeInterval': autoSnoozeInterval.inMilliseconds.toString(),
    };
  }

  // Will use fromJson and toJson methods of ReminderModel as the attributes
  // are same

  /// Generate DateTime for this new noRush reminder.
  /// Is used in the provider, when creating the new noRush reminder
  static DateTime generateRandomFutureTime(Ref ref) {
    final UserSettingsNotifier settings = ref.read(userSettingsProvider);
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

  NoRushReminderEntity get toEntity => NoRushReminderEntity(
        id: id,
        title: title,
        dateTime: dateTime,
        autoSnoozeInterval: autoSnoozeInterval.inSeconds,
      );
}
