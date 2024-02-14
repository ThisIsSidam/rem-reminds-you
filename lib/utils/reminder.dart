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
    int diff = dateAndTime.difference(DateTime.now()).inSeconds;

    if (diff > -60 && diff < 0)
    {
      return "seconds ago";
    }
    if (diff < 60)
    {
      return "about to go boom";
    }

    String diffStr = "";
    bool negative = false;

    if (diff < 0) 
    {
      negative = true;
      diff = diff.abs();
    }

    if (diff < 3600)
    {
      int min = (diff/60).ceil();
      if (negative == true)
      {
        min--;
      }

      diffStr += "$min minute${(min>1) ? "s":""}";
    }
    else if (diff < 7200)
    {
      diffStr += "1 hour${(diff>3600) ? ", ${((diff/60)-60).ceil()} minutes" : ""}";
    }
    else
    {
      diffStr += "${(diff/3600).ceil()} hours";
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
    final hashInt = int.parse(hashString.substring(0, 4), radix: 16);
    return hashInt;
  }

}
