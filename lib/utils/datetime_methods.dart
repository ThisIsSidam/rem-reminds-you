import 'package:duration/duration.dart';
import 'package:intl/intl.dart';

String getFormattedDateTime(DateTime dateTime) {
  final DateFormat formatter = DateFormat('EEE, d MMM, hh:mm aaa');
  final String formatted = formatter.format(dateTime);

  return formatted;
}

String getPrettyDurationFromDateTime(DateTime dateTime) {
  DateTime now = DateTime.now();
  Duration dur = dateTime.difference(DateTime(
    now.year,
    now.month,
    now.day,
    now.hour,
    now.minute
  )); 
  return dur.pretty(
    tersity: DurationTersity.minute
  );
}


String getFormattedTimeForTimeSetButton(DateTime time) {
  String suffix = time.hour >= 12 ? "PM" : "AM";
  int hour = time.hour % 12;
  hour = hour == 0 ? 12 : hour;
  String formattedTime =
      "$hour:${time.minute.toString().padLeft(2, '0')} $suffix";
  return formattedTime;
}

String getFormattedDurationForTimeEditButton(Duration dur,
    {bool addPlusSymbol = false}) {
  final minutes = dur.inMinutes;
  String strDuration = "";

  if (addPlusSymbol) {
    if (minutes > 0) {
      strDuration += "+";
    }
  }

  if ((minutes < 59) && (minutes > -59)) {
    strDuration += "${minutes.toString()} Min";
  } else if ((minutes < 1439) && (minutes > -1439)) {
    strDuration += "${(minutes ~/ 60).toString()} Hr";
  } else {
    strDuration += "${((minutes ~/ 60) ~/ 24).toString()} Day";
  }

  return strDuration;
}
