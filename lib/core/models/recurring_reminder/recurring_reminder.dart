import 'package:hive_ce_flutter/hive_flutter.dart';

import '../recurring_interval/recurring_interval.dart';
import '../reminder_model/reminder_model.dart';

part 'recurring_reminder.g.dart';

@HiveType(typeId: 1)
class RecurringReminderModel implements ReminderModel {
  RecurringReminderModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.preParsedTitle,
    required this.autoSnoozeInterval,
    required this.recurringInterval,
    required this.baseDateTime,
    this.paused = false,
  });

  factory RecurringReminderModel.fromJson(Map<String, String?> map) {
    return RecurringReminderModel(
      id: int.parse(map['id']!),
      title: map['title'] ?? '',
      dateTime: DateTime.parse(map['dateTime']!),
      autoSnoozeInterval:
          Duration(milliseconds: int.parse(map['autoSnoozeInterval']!)),
      preParsedTitle: map['preParsedTitle'] ?? '',
      recurringInterval:
          RecurringInterval.values[int.parse(map['recurringInterval']!)],
      baseDateTime: DateTime.parse(map['baseDateTime']!),
      paused: map['paused']! == 'true',
    );
  }
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
  @HiveField(10)
  RecurringInterval recurringInterval;
  @HiveField(11)
  DateTime baseDateTime;
  @HiveField(12)
  bool paused;

  @override
  Map<String, String?> toJson() {
    return <String, String?>{
      'id': id.toString(),
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'preParsedTitle': preParsedTitle,
      'autoSnoozeInterval': autoSnoozeInterval?.inMilliseconds.toString(),
      'recurringInterval': recurringInterval.index.toString(),
      'baseDateTime': baseDateTime.toIso8601String(),
      'paused': paused.toString(),
    };
  }

  @override
  RecurringReminderModel copyWith({
    int? id,
    String? title,
    DateTime? dateTime,
    Duration? autoSnoozeInterval,
    String? preParsedTitle,
    RecurringInterval? recurringInterval,
    DateTime? baseDateTime,
    bool? paused,
  }) {
    return RecurringReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      autoSnoozeInterval: autoSnoozeInterval ?? this.autoSnoozeInterval,
      preParsedTitle: preParsedTitle ?? this.preParsedTitle,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      baseDateTime: baseDateTime ?? this.baseDateTime,
      paused: paused ?? this.paused,
    );
  }

  void moveToNextOccurrence() {
    _incrementRecurDuration();
    dateTime = baseDateTime;
  }

  void moveToPreviousOccurrence() {
    _decrementRecurDuration();
    dateTime = baseDateTime;
  }

  void _incrementRecurDuration() {
    final Duration? increment =
        recurringInterval.getRecurringIncrementDuration(dateTime);

    if (increment != null) {
      baseDateTime = baseDateTime.add(increment);
    }
  }

  void _decrementRecurDuration() {
    final Duration? decrement =
        recurringInterval.getRecurringDecrementDuration(dateTime);

    if (decrement != null) {
      baseDateTime = baseDateTime.subtract(decrement);
    }
  }
}
