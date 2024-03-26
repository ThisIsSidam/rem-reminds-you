import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:nagger/consts/consts.dart';
part 'reminder.g.dart';

@HiveType(typeId: 1)
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

  Reminder({
    this.title = reminderNullTitle,
    this.repetitionCount = 0,
    this.repetitionInterval = const Duration(seconds: 5),
    required this.dateAndTime,
  }){
    id = newReminderID;
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

}
