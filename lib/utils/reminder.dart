import 'package:intl/intl.dart';

class Reminder {
  String? title;
  int? snoozeMinutes;
  DateTime? dateAndTime;
  bool set = false;

  Reminder({
    this.title = "",
    this.snoozeMinutes = 5,
    this.dateAndTime,
  });

  String getDateTimeAsStr() {
    final DateFormat formatter = DateFormat('EEE, d MMM, hh:mm aaa');
    final String formatted = formatter.format(dateAndTime!);
    final diff = dateAndTime!.difference(DateTime.now()).inMinutes;

    String diffStr = " in ";

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

    return formatted + diffStr;
  }

}
