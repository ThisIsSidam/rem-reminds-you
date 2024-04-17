import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:nagger/consts/consts.dart';

part 'reminder.g.dart';
part 'recurring_frequency.dart';

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
  bool done = false;

  @HiveField(4)
  int repetitionCount; 

  @HiveField(5)
  Duration repetitionInterval;

  @HiveField(6) 
  int _recurringFrequency = 0;

  @HiveField(7)
  bool recurringScheduleSet;

  Reminder({
    this.title = reminderNullTitle,
    required this.dateAndTime,
    this.done = false,
    this.repetitionCount = 0,
    this.repetitionInterval = const Duration(seconds: 5),
    RecurringFrequency recurringFrequency = RecurringFrequency.none,
    this.recurringScheduleSet = false
  }){
    id = newReminderID;
    
    this._recurringFrequency = RecurringFrequencyExtension.getIndex(recurringFrequency);
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
    if (duration.inSeconds < 60) 
    {
      // Remove number of seconds on release. Only 'seconds' should remain.
      return ' ${duration.inSeconds} seconds';
    } 
    else if (duration.inMinutes < 60) 
    {
      return '${duration.inMinutes} minute${duration.inMinutes != 1 ? 's' : ''}';
    } 
    else if (duration.inHours < 24) 
    {
      int hours = duration.inHours;
      String hoursString = hours == 1 ? 'hour' : 'hours';

      return '$hours $hoursString';
    } 
    else 
    {
      int days = duration.inDays;
      return '$days day${days != 1 ? 's' : ''}';
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
      done: reminder.done,
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
}

