import 'package:intl/intl.dart';

String getFormattedDateTime(DateTime dateTime) {
  final DateFormat formatter = DateFormat('EEE, d MMM, hh:mm aaa');
  final String formatted = formatter.format(dateTime);

  return formatted;
}

/// [input] argument is of dynamic typing but only DateTime and Duration are acceptable.
/// The method returns a formatted string of Duration, either drawn out from DateTime of the 
/// received Duration. 
/// 
/// Example of returns: "5 minutes ago", "in 2 hours".
String getFormattedDiffString(dynamic input) {
  Duration difference;
  if (input is DateTime) 
  {
    difference = input.difference(DateTime.now());
  }
  else if (input is Duration) 
  {
    difference = input;
  }
  else 
  {
    throw ArgumentError('Input must be DateTime or Duration');
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