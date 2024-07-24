import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  late int _reminderStatus; // Is an enum but saved as int coz saving enums in hive is a problem.

  @HiveField(4)
  late Duration notifRepeatInterval;

  @HiveField(5) 
  late int _recurringInterval; // Is an enum but saved as int coz saving enums in hive is a problem.

  Reminder({
    this.title = reminderNullTitle,
    required this.dateAndTime,
    this.id = newReminderID,
    ReminderStatus reminderStatus = ReminderStatus.active, 
    Duration? notifRepeatInterval,
    RecurringInterval? recurringInterval,
  }){
    // The three late lords
    // Lord 1 : _reminderStatus
    this._reminderStatus = RemindersStatusExtension.getIndex(reminderStatus);

    // Lord 2 : notifRepeatInterval
    if (notifRepeatInterval == null)
    {
      print("[ReminderConstructor] notifRepeat is null | Assigning.");
      this.notifRepeatInterval = UserDB.getSetting(SettingOption.RepeatIntervalFieldValue);
    }
    else this.notifRepeatInterval = notifRepeatInterval;

    // Lord 3 : _recurringInterval
    if (recurringInterval == null)
    {
      final recurringIntervalString = UserDB.getSetting(SettingOption.RecurringIntervalFieldValue);
      recurringInterval = RecurringIntervalExtension.fromString(recurringIntervalString);
    }
    this._recurringInterval = RecurringIntervalExtension.getIndex(recurringInterval);
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
      notifRepeatInterval: Duration(seconds: int.parse(_getValue('notifRepeatInterval'))),
      recurringInterval: RecurringIntervalExtension.fromInt(int.parse(_getValue('_recurringInterval'))),
    );
  }

  Map<String, String> toMap() {
    return {
      'title': title,
      'dateAndTime': dateAndTime.millisecondsSinceEpoch.toString(),
      'id': id.toString(),
      'done': _reminderStatus.toString(),
      'notifRepeatInterval': notifRepeatInterval.inSeconds.toString(),
      '_recurringInterval': _recurringInterval.toString(),
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

  Duration getDiffDuration() {
    return dateAndTime.difference(DateTime.now());
  }


  String getRecurringIntervalAsString() {
    return RecurringIntervalExtension.getDisplayName(
      RecurringIntervalExtension.fromInt(_recurringInterval)
    );
  }

  String getIntervalString() {
    final minutes = notifRepeatInterval.inMinutes;
    if (minutes == 1) return "minute";
    else return "${minutes} minutes";
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
    this.reminderStatus = reminder.reminderStatus;
    this.notifRepeatInterval = reminder.notifRepeatInterval;
    this.recurringInterval = reminder.recurringInterval;
  }

  Reminder deepCopyReminder() {
    return Reminder(
      id: this.id,
      title: this.title,
      dateAndTime: this.dateAndTime,
      reminderStatus: RemindersStatusExtension.fromInt(this._reminderStatus),
      notifRepeatInterval: this.notifRepeatInterval,
      recurringInterval: RecurringIntervalExtension.fromInt(this._recurringInterval),
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

