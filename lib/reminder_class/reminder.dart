import 'package:Rem/consts/consts.dart';
import 'package:Rem/reminder_class/field_mixins/date_and_time.dart';
import 'package:Rem/reminder_class/field_mixins/recur/recurring.dart';
import 'package:Rem/reminder_class/field_mixins/reminder_status/status.dart';
import 'package:Rem/reminder_class/field_mixins/repeat.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'field_mixins/recur/recurring_interval.dart';
part 'field_mixins/reminder_status/reminder_status.dart';
part 'reminder.g.dart';

@HiveType(typeId: 1)
class Reminder with Repeat, Recur, ReminderStatusMixin, ReminderDateTime{

  @HiveField(0)
  String title;

  @HiveField(1)
  int? id;

  // HiveField 2: DateAndTime
  // HiveField 3: reminderStatus
  // HiveField 4: notifRepeatDuration
  // HiveField 5: recurringInterval
  // HiveField 6: baseDateTime

  Reminder({
    this.title = reminderNullTitle,
    this.id = newReminderID,
    required DateTime dateAndTime,
    ReminderStatus reminderStatus = ReminderStatus.active, 
    Duration? notifInterval,
    RecurringInterval? recurInterval,
  }){

    this.dateAndTime = dateAndTime;
    this.mixinReminderStatus = RemindersStatusExtension.getIndex(reminderStatus);
    super.initRepeatInterval(notifInterval);
    super.initRecurringInterval(recurInterval);
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
      dateAndTime: DateTime.fromMillisecondsSinceEpoch(int.parse(_getValue('dateAndTime'))),
      id: int.parse(_getValue('id')),
      reminderStatus: RemindersStatusExtension.fromInt(int.parse(_getValue('done'))),
      notifInterval: Duration(seconds: int.parse(_getValue('notifRepeatInterval'))),
      recurInterval: RecurringIntervalExtension.fromInt(int.parse(_getValue('_recurringInterval'))),
    );
  }

  Map<String, String> toMap() {
    return {
      'title': title,
      'dateAndTime': dateAndTime.millisecondsSinceEpoch.toString(),
      'id': id.toString(),
      'done': mixinReminderStatus.toString(),
      'notifRepeatInterval': notifRepeatInterval.inSeconds.toString(),
      '_recurringInterval': mixinRecurringInterval.toString(),
    };
  }

  Duration getDiffDuration() {
    return dateAndTime.difference(DateTime.now());
  }

  void set(Reminder reminder) {
    this.title = reminder.title;
    this.dateAndTime = reminder.dateAndTime;
    this.id = reminder.id;
    this.reminderStatus = reminder.reminderStatus;
    this.notifRepeatInterval = reminder.notifRepeatInterval;
    this.recurringInterval = reminder.recurringInterval;
  }

  Reminder deepCopyReminder() {
    return Reminder(
      id: this.id,
      title: this.title,
      dateAndTime: this.dateAndTime,
      reminderStatus: RemindersStatusExtension.fromInt(this.mixinReminderStatus),
      notifInterval: this.notifRepeatInterval,
      recurInterval: RecurringIntervalExtension.fromInt(this.mixinRecurringInterval),
    );
  }

  /// Increment the date and time by 1 day or 1 week depending on the repeat interval.
  void incrementRecurDuration() {
    final increment = getRecurIncrementDuration();

    if (increment != null) {
      dateAndTime = dateAndTime.add(increment);
    }
  }
}