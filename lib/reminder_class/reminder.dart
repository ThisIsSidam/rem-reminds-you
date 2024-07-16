import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:Rem/consts/consts.dart';

part 'reminder.g.dart';
part 'recurring_interval.dart';
part 'reminder_status.dart';

@HiveType(typeId: 1)
/// Holds data for reminders. All attributes are easy to understand.
/// But the terms [Repetitive] and [Recurring] may cuase some confusion.
/// The term [Repetition] is used for repetition of notification and not the reminder
/// itself. It is for the nagging effect the notifications may have.
/// The term [Recurring] is used for recurrence of reminder, on daily basis or any other.
class Reminder {

  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime dateAndTime;

  @HiveField(2)
  int? id;

  @HiveField(3)
  int _reminderStatus = 0; // Is an enum but saved as int coz saving enums in hive is a problem.

  @HiveField(4)
  Duration notifRepeatInterval;

  @HiveField(5) 
  int _recurringInterval = 0; // Is an enum but saved as int coz saving enums in hive is a problem.

  Reminder({
    this.title = reminderNullTitle,
    required this.dateAndTime,
    this.id = newReminderID,
    ReminderStatus reminderStatus = ReminderStatus.active, 
    this.notifRepeatInterval = const Duration(minutes: 10),
    RecurringInterval recurringInterval = RecurringInterval.none,
  }){
    this._recurringInterval = RecurringIntervalExtension.getIndex(recurringInterval);
    this._reminderStatus = RemindersStatusExtension.getIndex(reminderStatus);
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      title: map['title'],
      dateAndTime: DateTime.fromMillisecondsSinceEpoch(map['dateAndTime']),
      id: map['id'],
      reminderStatus: RemindersStatusExtension.fromInt(map['done'] ?? 0),
      notifRepeatInterval: Duration(seconds: map['notifRepeatInterval']),
      recurringInterval: RecurringIntervalExtension.fromInt(map['_recurringInterval']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dateAndTime': dateAndTime.millisecondsSinceEpoch,
      'id': id,
      'done': _reminderStatus,
      'notifRepeatInterval': notifRepeatInterval.inSeconds,
      '_recurringInterval': _recurringInterval,
    };
  }

  ReminderStatus get reminderStatus {
    return RemindersStatusExtension.fromInt(_reminderStatus);
  }

  void set reminderStatus(ReminderStatus status) {
    _reminderStatus = RemindersStatusExtension.getIndex(status);
  }

  RecurringInterval get recurringInterval {
    return RecurringIntervalExtension.fromInt(_recurringInterval);
  }

  void set recurringInterval(RecurringInterval interval) {
    _recurringInterval = RecurringIntervalExtension.getIndex(interval);
  }

  String getDateTimeAsStr() {
    final DateFormat formatter = DateFormat('EEE, d MMM, hh:mm aaa');
    final String formatted = formatter.format(dateAndTime);

    return formatted;
  }

  Duration getDiffDuration() {
    return dateAndTime.difference(DateTime.now());
  }

  String getDiffString() {
    Duration difference = dateAndTime.difference(DateTime.now());

    if (difference.isNegative) 
    {
      difference = difference.abs();
      return "${_formatDuration(difference)} ago";
    } 
    else 
    {
      return "in ${_formatDuration(difference)}";
    }
  }

  String getRecurringIntervalAsString() {
    return RecurringIntervalExtension.getDisplayName(
      RecurringIntervalExtension.fromInt(_recurringInterval)
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 11) 
    {
      return 'seconds';
    }
    else if (duration.inSeconds < 60)
    {
      return 'a minute';
    } 
    else if (duration.inMinutes < 60) 
    {
      return '${duration.inMinutes+1} minutes';
    } 
    else if (duration.inHours < 24) 
    {
      int hours = duration.inHours +1;

      return '$hours hours';
    } 
    else 
    {
      int days = duration.inDays + 1;
      return '$days days';
    }
  }

  String getIntervalString() {
    return "${notifRepeatInterval.inMinutes} minutes";
  }

  /// If the time to be updated is in the past, increase it by a day.
  void updatedTime(DateTime updatedTime) {
    if (updatedTime.isBefore(DateTime.now()))
    {
      updatedTime = updatedTime.add(Duration(days: 1));
    }
    updatedTime = DateTime( // Seconds should be 0
      updatedTime.year,
      updatedTime.month,
      updatedTime.day,
      updatedTime.hour,
      updatedTime.minute,
      0
    );
    dateAndTime = updatedTime;
  }

  void set(Reminder reminder) {
    this.title = reminder.title;
    this.dateAndTime = reminder.dateAndTime;
    this.id = reminder.id;
    this.notifRepeatInterval = reminder.notifRepeatInterval;
  }

  static Reminder deepCopyReminder(Reminder reminder) {
    return Reminder(
      id: reminder.id,
      title: reminder.title,
      dateAndTime: reminder.dateAndTime,
      reminderStatus: RemindersStatusExtension.fromInt(reminder._reminderStatus),
      notifRepeatInterval: reminder.notifRepeatInterval
    );
  }

  /// Increment the date and time by 1 day or 1 week depending on the repeat interval.
  void incrementRepeatDuration() {

    if (_recurringInterval == RecurringInterval.none)
    {
      return;
    }

    final recurringInterval = RecurringIntervalExtension.fromInt(_recurringInterval);

    Duration increment;

    if (recurringInterval == RecurringInterval.daily)
    {
      increment = Duration(days: 1);
    }
    else if (recurringInterval == RecurringInterval.weekly)
    {
      increment = Duration(days: 7);
    }
    else 
    {
      return;
    }

    dateAndTime = dateAndTime.add(increment);
  }

  /// Check if the current date and time is before 5 seconds from the reminder's date and time.
  bool isTimesUp() {
    return dateAndTime.isBefore(DateTime.now().add(Duration(seconds: 5)));
  }
}

