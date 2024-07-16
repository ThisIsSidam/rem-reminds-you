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
  int repetitionCount; 

  @HiveField(5)
  Duration recurringInterval;

  @HiveField(6) 
  int _repeatInterval = 0; // Is an enum but saved as int coz saving enums in hive is a problem.

  @HiveField(7)
  bool recurringScheduleSet;

  Reminder({
    this.title = reminderNullTitle,
    required this.dateAndTime,
    this.id = newReminderID,
    ReminderStatus reminderStatus = ReminderStatus.active, 
    this.repetitionCount = 0,
    this.recurringInterval = const Duration(minutes: 10),
    RepeatInterval repeatInterval = RepeatInterval.none,
    this.recurringScheduleSet = false
  }){
    this._repeatInterval = RepeatIntervalExtension.getIndex(repeatInterval);
    this._reminderStatus = RemindersStatusExtension.getIndex(reminderStatus);
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      title: map['title'],
      dateAndTime: DateTime.fromMillisecondsSinceEpoch(map['dateAndTime']),
      id: map['id'],
      reminderStatus: RemindersStatusExtension.fromInt(map['done'] ?? 0),
      repetitionCount: map['repetitionCount'] ?? 0,
      recurringInterval: Duration(seconds: map['recurringInterval']),
      repeatInterval: RepeatIntervalExtension.fromInt(map['_repeatInterval']),
      recurringScheduleSet: map['recurringScheduleSet'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dateAndTime': dateAndTime.millisecondsSinceEpoch,
      'id': id,
      'done': _reminderStatus,
      'repetitionCount': repetitionCount,
      'recurringInterval': recurringInterval.inSeconds,
      '_repeatInterval': _repeatInterval,
      'recurringScheduleSet': recurringScheduleSet,
    };
  }

  ReminderStatus get reminderStatus {
    return RemindersStatusExtension.fromInt(_reminderStatus);
  }

  void set reminderStatus(ReminderStatus status) {
    _reminderStatus = RemindersStatusExtension.getIndex(status);
  }

  RepeatInterval get repeatInterval {
    return RepeatIntervalExtension.fromInt(_repeatInterval);
  }

  void set repeatInterval(RepeatInterval interval) {
    _repeatInterval = RepeatIntervalExtension.getIndex(interval);
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

  String getRepeatIntervalAsString() {
    return RepeatIntervalExtension.getDisplayName(
      RepeatIntervalExtension.fromInt(_repeatInterval)
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
    return "${recurringInterval.inMinutes} minutes";
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
    this.repetitionCount = reminder.repetitionCount;
    this.recurringInterval = reminder.recurringInterval;
  }

  static Reminder deepCopyReminder(Reminder reminder) {
    return Reminder(
      id: reminder.id,
      title: reminder.title,
      dateAndTime: reminder.dateAndTime,
      reminderStatus: RemindersStatusExtension.fromInt(reminder._reminderStatus),
      repetitionCount: reminder.repetitionCount,
      recurringInterval: reminder.recurringInterval
    );
  }

  /// Increment the date and time by 1 day or 1 week depending on the repeat interval.
  void incrementRepeatDuration() {

    if (_repeatInterval == RepeatInterval.none)
    {
      return;
    }

    final repeatInterval = RepeatIntervalExtension.fromInt(_repeatInterval);

    Duration increment;

    if (repeatInterval == RepeatInterval.daily)
    {
      increment = Duration(days: 1);
    }
    else if (repeatInterval == RepeatInterval.weekly)
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

