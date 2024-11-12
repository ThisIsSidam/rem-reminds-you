import 'package:Rem/consts/consts.dart';
import 'package:Rem/reminder_class/field_mixins/date_and_time.dart';
import 'package:Rem/reminder_class/field_mixins/pre_parsed_title.dart';
import 'package:Rem/reminder_class/field_mixins/recur/recurring.dart';
import 'package:Rem/reminder_class/field_mixins/reminder_status/status.dart';
import 'package:Rem/reminder_class/field_mixins/repeat.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'field_mixins/recur/recurring_interval.dart';
part 'reminder.g.dart';

@HiveType(typeId: 1)
class Reminder
    with Repeat, Recur, ReminderStatusMixin, ReminderDateTime, PreParsedTitle {
  @HiveField(0)
  String title;

  @HiveField(1)
  int id;

  // These are all in their individual files in field_mixins folder
  // HiveField 2: DateAndTime
  // HiveField 3: reminderStatus
  // HiveField 4: autoSnoozeInteval
  // HiveField 5: recurringInterval
  // HiveField 6: baseDateTime
  // HiveField 7: preParsedTitle

  Reminder({
    this.title = reminderNullTitle,
    this.id = newReminderID,
    required DateTime dateAndTime,
    DateTime? baseDateTime,
    ReminderStatus reminderStatus = ReminderStatus.active,
    Duration autoSnoozeInterval = const Duration(minutes: 7),
    RecurringInterval? recurInterval,
    String? preParsedTitle,
  }) {
    this.dateAndTime = dateAndTime;
    this.reminderStatus = reminderStatus;
    this.baseDateTime =
        baseDateTime ?? this.dateAndTime; // Same in the beginning
    super.autoSnoozeInterval = autoSnoozeInterval;
    super.recurringInterval = recurInterval ?? RecurringInterval.none;
    this.preParsedTitle = preParsedTitle ?? this.title;
  }

  factory Reminder.fromMap(Map<String, String?> map) {
    String _getValue(String key) {
      final value = map[key];
      if (value == null) {
        throw FormatException('Missing required key: $key');
      }
      return value;
    }

    return Reminder(
      title: _getValue('title'),
      id: int.parse(_getValue('id')),
      dateAndTime: DateTime.fromMillisecondsSinceEpoch(
          int.parse(_getValue('dateAndTime'))),
      baseDateTime: DateTime.fromMillisecondsSinceEpoch(
          int.parse(_getValue('baseDateTime'))),
      reminderStatus:
          RemindersStatusExtension.fromInt(int.parse(_getValue('done'))),
      autoSnoozeInterval:
          Duration(seconds: int.parse(_getValue('notifRepeatInterval'))),
      recurInterval:
          RecurringInterval.fromInt(int.parse(_getValue('_recurringInterval'))),
    );
  }

  Map<String, String> toMap() {
    return {
      'title': title,
      'id': id.toString(),
      'dateAndTime': dateAndTime.millisecondsSinceEpoch.toString(),
      'baseDateTime': baseDateTime.millisecondsSinceEpoch.toString(),
      'done': mixinReminderStatus.toString(),
      'notifRepeatInterval': autoSnoozeInterval.inSeconds.toString(),
      '_recurringInterval': mixinRecurringInterval.toString(),
    };
  }

  Duration getDiffDuration() {
    return dateAndTime.difference(DateTime.now());
  }

  void set(Reminder reminder) {
    this.title = reminder.title;
    this.dateAndTime = this.dateAndTime.copyWith();
    this.id = reminder.id;
    this.baseDateTime = reminder.baseDateTime;
    this.reminderStatus = reminder.reminderStatus;
    this.autoSnoozeInterval = reminder.autoSnoozeInterval;
    this.recurringInterval = reminder.recurringInterval;
    this.preParsedTitle = reminder.preParsedTitle;
  }

  Reminder deepCopyReminder() {
    return Reminder(
        id: this.id,
        title: this.title,
        dateAndTime: this.dateAndTime,
        baseDateTime: this.baseDateTime,
        reminderStatus:
            RemindersStatusExtension.fromInt(this.mixinReminderStatus),
        autoSnoozeInterval: this.autoSnoozeInterval,
        recurInterval: RecurringInterval.fromInt(this.mixinRecurringInterval),
        preParsedTitle: this.preParsedTitle);
  }

  void moveToNextOccurence() {
    _incrementRecurDuration();
    dateAndTime = baseDateTime;
  }

  void moveToPreviousOccurence() {
    _decrementRecurDuration();
    dateAndTime = baseDateTime;
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
}
