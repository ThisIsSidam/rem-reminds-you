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