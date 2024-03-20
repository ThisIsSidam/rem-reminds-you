import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
part 'reminder.g.dart';

@HiveType(typeId: 1)
class Reminder {

  @HiveField(0)
  String? title;

  @HiveField(1)
  int? snoozeMinutes;

  @HiveField(2)
  DateTime dateAndTime;

  @HiveField(3)
  int? id;

  @HiveField(4)
  bool done = false;

  Reminder({
    this.title,
    this.snoozeMinutes = 5,
    required this.dateAndTime,
  }){
    id = 101;
  }

  String getDateTimeAsStr() {
    final DateFormat formatter = DateFormat('EEE, d MMM, hh:mm aaa');
    final String formatted = formatter.format(dateAndTime);

    return formatted;
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
      return 'seconds';
    } 
    else if (duration.inMinutes < 60) 
    {
      return '${duration.inMinutes} minute${duration.inMinutes != 1 ? 's' : ''}';
    } 
    else if (duration.inHours < 24) 
    {
      int hours = duration.inHours;
      int minutes = duration.inMinutes.remainder(60);
      String hoursString = hours == 1 ? 'hour' : 'hours';
      String minutesString = minutes == 1 ? 'minute' : 'minutes';
      return '$hours $hoursString${minutes > 0 ? ', $minutes $minutesString' : ''}';
    } 
    else 
    {
      int days = duration.inDays;
      return '$days day${days != 1 ? 's' : ''}';
    }
  }

  Duration getDiffDuration() {
    return dateAndTime.difference(DateTime.now());
  }

  String hash() {
    String str = "${title ?? "new"}${getDateTimeAsStr()}";
    return sha256.convert(utf8.encode(str)).toString();
  }

  int getID() {
    final hashString = hash();
    final hashInt = int.parse(hashString.substring(0, 4), radix: 16);
    return hashInt;
  }

}
