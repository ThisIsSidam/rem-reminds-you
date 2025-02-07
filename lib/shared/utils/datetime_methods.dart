import 'package:duration/duration.dart';
import 'package:intl/intl.dart';

import '../../core/models/reminder_model/reminder_model.dart';

String getFormattedDateTime(DateTime dateTime) {
  final DateFormat formatter = DateFormat('EEE, d MMM, hh:mm aaa');
  final String formatted = formatter.format(dateTime);

  return formatted;
}

String getFormattedDuration(ReminderModel reminder) {
  if (reminder.dateTime.isBefore(DateTime.now())) {
    return '${getPrettyDurationFromDateTime(reminder.dateTime)} ago'
        .replaceFirst('-', '');
  } else {
    return 'in ${getPrettyDurationFromDateTime(reminder.dateTime)}';
  }
}

String getPrettyDurationFromDateTime(DateTime dateTime) {
  final DateTime now = DateTime.now();
  final Duration dur = dateTime
      .difference(DateTime(now.year, now.month, now.day, now.hour, now.minute));
  return dur.pretty(
    tersity: DurationTersity.minute,
    maxUnits: 2,
    abbreviated: true,
  );
}

String getFormattedTimeForTimeSetButton(DateTime time) {
  final String suffix = time.hour >= 12 ? 'PM' : 'AM';
  int hour = time.hour % 12;
  hour = hour == 0 ? 12 : hour;
  final String formattedTime =
      "$hour:${time.minute.toString().padLeft(2, '0')} $suffix";
  return formattedTime;
}

String getFormattedDurationForTimeEditButton(
  Duration dur, {
  bool addPlusSymbol = false,
}) {
  final int minutes = dur.inMinutes;
  String strDuration = '';

  if (addPlusSymbol) {
    if (minutes > 0) {
      strDuration += '+';
    }
  }

  if ((minutes < 59) && (minutes > -59)) {
    strDuration += '$minutes Min';
  } else if ((minutes < 1439) && (minutes > -1439)) {
    strDuration += '${minutes ~/ 60} Hr';
  } else {
    strDuration += '${(minutes ~/ 60) ~/ 24} Day';
  }

  return strDuration;
}
