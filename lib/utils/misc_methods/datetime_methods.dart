import 'package:intl/intl.dart';

String getFormattedDateTime(DateTime dateTime) {
  final DateFormat formatter = DateFormat('EEE, d MMM, hh:mm aaa');
  final String formatted = formatter.format(dateTime);

  return formatted;
}

String getFormattedDiffString(DateTime dateTime) {
  Duration difference = dateTime.difference(DateTime.now());

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
    if (duration.inSeconds < 11) 
    {
      return 'seconds';
    }
    else if (duration.inSeconds < 60)
    {
      return 'a minute';
    } 
    else if (duration.inMinutes < 60) 
    {
      return '${duration.inMinutes+1} minutes';
    } 
    else if (duration.inHours < 24) 
    {
      int hours = duration.inHours +1;

      return '$hours hours';
    } 
    else 
    {
      int days = duration.inDays + 1;
      return '$days days';
    }
  }