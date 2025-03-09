import 'package:flutter/material.dart';
import 'package:random_datetime/random_datetime.dart';
import 'package:random_datetime/random_dt_options.dart';

import '../../entities/no_rush_entitiy/no_rush_entity.dart';
import '../reminder_base/reminder_base.dart';

class NoRushReminderModel implements ReminderBase {
  NoRushReminderModel({
    required this.id,
    required this.title,
    required this.autoSnoozeInterval,
    required this.dateTime,
  });

  factory NoRushReminderModel.fromJson(Map<String, String?> map) {
    return NoRushReminderModel(
      id: int.parse(map['id']!),
      title: map['title'] ?? '',
      dateTime: DateTime.parse(map['dateTime']!),
      autoSnoozeInterval:
          Duration(seconds: int.parse(map['autoSnoozeInterval']!)),
    );
  }

  @override
  int id;
  @override
  String title;
  @override
  DateTime dateTime;
  @override
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

  @override
  Map<String, String?> toJson() {
    return <String, String>{
      'id': id.toString(),
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'autoSnoozeInterval': autoSnoozeInterval.inSeconds.toString(),
      'type': '2',
    };
  }

  // Will use fromJson and toJson methods of ReminderModel as the attributes
  // are same

  /// Generate DateTime for this new noRush reminder.
  /// Is used in the provider, when creating the new noRush reminder
  static DateTime generateRandomFutureTime(
    TimeOfDay startTime,
    TimeOfDay endTime,
  ) {
    final DateTime now = DateTime.now();
    final DateTime startDate = now.add(const Duration(days: 3));
    final DateTime endDate = now.add(const Duration(days: 14));

    final RandomDateTime randomTime = RandomDateTime(
      options: RandomDTOptions.withRange(
        yearRange: TimeRange(start: startDate.year, end: endDate.year),
        monthRange: TimeRange(start: startDate.month, end: endDate.month),
        dayRange: TimeRange(start: startDate.day, end: endDate.day),
        hourRange: TimeRange(start: startTime.hour, end: endTime.hour),
        minuteRange: TimeRange(start: startTime.minute, end: endTime.minute),
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
