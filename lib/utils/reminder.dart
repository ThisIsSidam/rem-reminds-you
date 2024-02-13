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
    int diff = dateAndTime.difference(DateTime.now()).inMinutes;

    String diffStr = "";
    bool negative = false;

    if (diff < 0) 
    {
      negative = true;
      diff = diff.abs();
    }


    if (diff > 119)
    {
      diffStr += "${(diff/60).floor()} hours";
    }
    else if (diff > 59)
    {
      diffStr += "1 hour, ${diff-60} minutes";
    }
    else
    {
      diffStr += "$diff minutes";
    }

    if (negative == true) 
    {
      return "$diffStr ago";
    }
    else 
    {
      return "in $diffStr";
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
    final hashInt = int.parse(hashString.substring(0, 8), radix: 16);
    return hashInt;
  }


}
