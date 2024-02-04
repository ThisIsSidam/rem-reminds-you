import 'package:hive_flutter/hive_flutter.dart';
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
  String? id;

  Reminder({
    this.title,
    this.snoozeMinutes = 5,
    required this.dateAndTime,
  }){
    id = getId();
  }

  String getDateTimeAsStr() {
    final DateFormat formatter = DateFormat('EEE, d MMM, hh:mm aaa');
    final String formatted = formatter.format(dateAndTime);

    return formatted;
  }

  String getDiff() {
    final diff = dateAndTime.difference(DateTime.now()).inMinutes;
    String diffStr = "in ";

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
      diffStr += "${diff+1} minutes";
    }

    return diffStr;
  }

  String getId() {
    return "${title ?? "new"}${getDateTimeAsStr()}";
  }

}
