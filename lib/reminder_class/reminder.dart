import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:Rem/consts/consts.dart';

part 'reminder.g.dart';
part 'recurring_frequency.dart';
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
  Duration repetitionInterval;

  @HiveField(6) 
  int _recurringFrequency = 0; // Is an enum but saved as int coz saving enums in hive is a problem.

  @HiveField(7)
  bool recurringScheduleSet;

  Reminder({
    this.title = reminderNullTitle,
    required this.dateAndTime,
    this.id = newReminderID,
    ReminderStatus reminderStatus = ReminderStatus.active, 
    this.repetitionCount = 0,
    this.repetitionInterval = const Duration(seconds: 5),
    RecurringFrequency recurringFrequency = RecurringFrequency.none,
    this.recurringScheduleSet = false
  }){
    this._recurringFrequency = RecurringFrequencyExtension.getIndex(recurringFrequency);
    this._reminderStatus = RemindersStatusExtension.getIndex(reminderStatus);
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      title: map['title'],
      dateAndTime: DateTime.fromMillisecondsSinceEpoch(map['dateAndTime']),
      id: map['id'],
      reminderStatus: RemindersStatusExtension.fromInt(map['done'] ?? 0),
      repetitionCount: map['repetitionCount'] ?? 0,
      repetitionInterval: Duration(seconds: map['repetitionInterval']),
      recurringFrequency: RecurringFrequencyExtension.fromInt(map['_recurringFrequency']),
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
      'repetitionInterval': repetitionInterval.inSeconds,
      '_recurringFrequency': _recurringFrequency,
      'recurringScheduleSet': recurringScheduleSet,
    };
  }

  ReminderStatus get reminderStatus {
    return RemindersStatusExtension.fromInt(_reminderStatus);
  }

  void set reminderStatus(ReminderStatus status) {
    _reminderStatus = RemindersStatusExtension.getIndex(status);
  }

  RecurringFrequency get recurringFrequency {
    return RecurringFrequencyExtension.fromInt(_recurringFrequency);
  }

  void set recurringFrequency(RecurringFrequency frequency) {
    _recurringFrequency = RecurringFrequencyExtension.getIndex(frequency);
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

  String getRecurringFrequencyAsString() {
    return RecurringFrequencyExtension.getDisplayName(
      RecurringFrequencyExtension.fromInt(_recurringFrequency)
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

  String hash() {
    String str = "${title}${getDateTimeAsStr()}";
    return sha256.convert(utf8.encode(str)).toString();
  }

  int getID() {
    final hashString = hash();
    final hashInt = int.parse(hashString.substring(0, 4), radix: 16);

    if ((hashInt == 101) || (hashInt == 7))
    {
      getID();
    }
    return hashInt;
  }

  String getIntervalString() {
    return _formatDuration(repetitionInterval);
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
    this.repetitionInterval = reminder.repetitionInterval;
  }

  static Reminder deepCopyReminder(Reminder reminder) {
    return Reminder(
      title: reminder.title,
      dateAndTime: reminder.dateAndTime,
      reminderStatus: RemindersStatusExtension.fromInt(reminder._reminderStatus),
      repetitionCount: reminder.repetitionCount,
      repetitionInterval: reminder.repetitionInterval
    );
  }

  Duration recurringToAdd() {

    if (_recurringFrequency == RecurringFrequency.none)
    {
      return Duration(seconds: 0);
    }

    final recurringFrequencyNotInt = RecurringFrequencyExtension.fromInt(_recurringFrequency);

    if (recurringFrequencyNotInt == RecurringFrequency.daily)
    {
      return Duration(days: 1);
    }
    else if (recurringFrequencyNotInt == RecurringFrequency.weekly)
    {
      return Duration(days: 7);
    }
    else 
    {
      return Duration(seconds: 0);
    }
  }

  /// Check if the current date and time is before 5 seconds from the reminder's date and time.
  bool isTimesUp() {
    return dateAndTime.isBefore(DateTime.now().add(Duration(seconds: 5)));
  }
}

