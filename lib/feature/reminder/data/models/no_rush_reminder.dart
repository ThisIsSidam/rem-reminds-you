import 'dart:math';

import 'package:flutter/material.dart';

import '../entities/no_rush_entity.dart';
import 'reminder_base.dart';

/// One of the implementations of [ReminderBase].
/// Data-wise, this is same as [ReminderBase]. Its name
/// is used to differentiate it for its purpose.
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
      autoSnoozeInterval: Duration(
        seconds: int.parse(map['autoSnoozeInterval']!),
      ),
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
    final now = DateTime.now();
    final random = Random();

    // Pick a random future date (3 → 14 days ahead)
    // nextInt(12) gives 0–11 → +3 shifts it to 3–14
    final int dayOffset = 3 + random.nextInt(12);

    // This is the base date (only date matters, not time yet)
    final DateTime baseDate = now.add(Duration(days: dayOffset));

    // Convert TimeOfDay → total minutes
    // Easier to work with a single number instead of hour+minute
    final int startMinutes = startTime.hour * 60 + startTime.minute;
    final int endMinutes = endTime.hour * 60 + endTime.minute;

    // Calculate duration between start and end time
    // Case 1: Normal range (e.g. 9 → 18)
    // Case 2: Overnight range (e.g. 22 → 6)
    final int totalMinutes = endMinutes >= startMinutes
        ? endMinutes - startMinutes
        // Wrap around midnight
        : (1440 - startMinutes + endMinutes);

    // Pick a random offset inside that time window
    final int randomMinutesOffset = random.nextInt(totalMinutes + 1);

    // Add offset to start time
    // %1440 ensures we stay within a 24-hour clock
    final int finalMinutes = (startMinutes + randomMinutesOffset) % 1440;

    // Convert back to hour + minute
    final int hour = finalMinutes ~/ 60;
    final int minute = finalMinutes % 60;

    // Combine date + time into final DateTime
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }

  NoRushReminderEntity get toEntity => NoRushReminderEntity(
    id: id,
    title: title,
    dateTime: dateTime,
    autoSnoozeInterval: autoSnoozeInterval.inSeconds,
  );
}
