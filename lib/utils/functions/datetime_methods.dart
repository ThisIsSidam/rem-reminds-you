import 'package:intl/intl.dart';

String getFormattedDateTime(DateTime dateTime) {
  final DateFormat formatter = DateFormat('EEE, d MMM, hh:mm aaa');
  final String formatted = formatter.format(dateTime);

  return formatted;
}

String getFormattedDiffString({DateTime? dateTime, Duration? duration}) {

  Duration difference;
  if (dateTime != null)
  {
    difference = dateTime.difference(DateTime.now());
  }
  else if (duration != null)
  {
    difference = duration;
  }
  else 
  {
    throw ArgumentError("[getFormattedDiffString] Both dateTime and duration are null");
  }

  difference += Duration(minutes: 1);
  if (difference.isNegative) 
  {
    difference = difference.abs();
    return "${formatDuration(difference)} ago";
  } 
  else 
  {
    return "in ${formatDuration(difference)}";
  }
}

String formatDuration(Duration duration) {
  if (duration.inSeconds < 60)
  {
    return 'a minute';
  } 
  else if (duration.inMinutes < 60) 
  {
    return '${duration.inMinutes} minutes';
  } 
  else if (duration.inHours < 24) 
  {
    int hours = duration.inHours;

    return '$hours hours';
  } 
  else 
  {
    int days = duration.inDays;
    return '$days days';
  }
}

String getFormattedTimeForTimeSetButton(DateTime time) {
  String suffix = time.hour >= 12 ? "PM" : "AM";
  int hour = time.hour % 12;
  hour = hour == 0 ? 12 : hour;
  String formattedTime = "$hour:${time.minute.toString().padLeft(2, '0')} $suffix";
  return formattedTime;
}

String getFormattedDurationForTimeEditButton(Duration dur) {
  final minutes = dur.inMinutes;
  String strDuration = "";

  if (minutes > 0)
  {
    strDuration += "+";
  }

  if ((minutes < 59) && (minutes > -59))
  {
    strDuration += "${minutes.toString()} min";
  }
  else if ( (minutes < 1439) && (minutes > -1439))
  {
    strDuration += "${(minutes~/60).toString()} hr";
  }
  else 
  {
    strDuration += "${((minutes~/60)~/24).toString()} day";
  }

  return strDuration;
}