import 'package:hive/hive.dart';

import '../recurring_interval/recurring_interval.dart';
import '../reminder_modal/reminder_modal.dart';

part 'recurring_reminder.g.dart';

@HiveType(typeId: 1)
class RecurringReminderModal extends ReminderModal {
  @HiveField(10)
  RecurringInterval recurringInterval;
  @HiveField(11)
  DateTime baseDateTime;
  @HiveField(12)
  bool paused;

  RecurringReminderModal({
    required super.id,
    required super.title,
    required super.dateTime,
    required super.PreParsedTitle,
    required super.autoSnoozeInterval,
    required this.recurringInterval,
    required this.baseDateTime,
    this.paused = false,
  });

  @override
  Map<String, String?> toJson() {
    final data = super.toJson();
    data['recurringInterval'] = recurringInterval.index.toString();
    data['baseDateTime'] = baseDateTime.toIso8601String();
    data['paused'] = paused.toString();
    return data;
  }

  factory RecurringReminderModal.fromJson(Map<String, String?> map) {
    return RecurringReminderModal(
      id: int.parse(map['id']!),
      title: map['title']!,
      dateTime: DateTime.parse(map['dateTime']!),
      autoSnoozeInterval:
          Duration(milliseconds: int.parse(map['autoSnoozeInterval']!)),
      PreParsedTitle: map['PreParsedTitle']!,
      recurringInterval:
          RecurringInterval.values[int.parse(map['recurringInterval']!)],
      baseDateTime: DateTime.parse(map['baseDateTime']!),
      paused: map['paused']! == 'true',
    );
  }

  RecurringReminderModal copyWithRecurring({
    int? id,
    String? title,
    DateTime? dateTime,
    Duration? autoSnoozeInterval,
    String? PreParsedTitle,
    RecurringInterval? recurringInterval,
    DateTime? baseDateTime,
    bool? paused,
  }) {
    return RecurringReminderModal(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      autoSnoozeInterval: autoSnoozeInterval ?? this.autoSnoozeInterval,
      PreParsedTitle: PreParsedTitle ?? this.PreParsedTitle,
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

  /// Increment the date and time by 1 day or 1 week depending on the repeat interval.
  void _incrementRecurDuration() {
    final increment = getRecurIncrementDuration();

    if (increment != null) {
      baseDateTime = baseDateTime.add(increment);
    }
  }

  void _decrementRecurDuration() {
    final decrement = getRecurIncrementDuration();

    if (decrement != null) {
      baseDateTime = baseDateTime.subtract(decrement);
    }
  }

  Duration? getRecurIncrementDuration() {
    if (recurringInterval == RecurringInterval.daily) {
      return Duration(days: 1);
    } else if (recurringInterval == RecurringInterval.weekly) {
      return Duration(days: 7);
    } else {
      return null;
    }
  }
}
