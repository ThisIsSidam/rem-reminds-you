import 'package:hive_ce_flutter/hive_flutter.dart';

import '../recurring_interval/recurring_interval.dart';
import '../reminder_model/reminder_model.dart';

part 'recurring_reminder.g.dart';

@HiveType(typeId: 1)
class RecurringReminderModel extends ReminderModel {
  RecurringReminderModel({
    required super.id,
    required super.title,
    required super.dateTime,
    required super.preParsedTitle,
    required super.autoSnoozeInterval,
    required this.recurringInterval,
    required this.baseDateTime,
    this.paused = false,
  });

  factory RecurringReminderModel.fromJson(Map<String, String?> map) {
    return RecurringReminderModel(
      id: int.parse(map['id']!),
      title: map['title']!,
      dateTime: DateTime.parse(map['dateTime']!),
      autoSnoozeInterval:
          Duration(milliseconds: int.parse(map['autoSnoozeInterval']!)),
      preParsedTitle: map['preParsedTitle']!,
      recurringInterval:
          RecurringInterval.values[int.parse(map['recurringInterval']!)],
      baseDateTime: DateTime.parse(map['baseDateTime']!),
      paused: map['paused']! == 'true',
    );
  }
  @HiveField(10)
  RecurringInterval recurringInterval;
  @HiveField(11)
  DateTime baseDateTime;
  @HiveField(12)
  bool paused;

  @override
  Map<String, String?> toJson() {
    final Map<String, String?> data = super.toJson();
    data['recurringInterval'] = recurringInterval.index.toString();
    data['baseDateTime'] = baseDateTime.toIso8601String();
    data['paused'] = paused.toString();
    return data;
  }

  RecurringReminderModel copyWithRecurring({
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
