import 'package:duration/duration.dart';
import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String get friendly {
    final DateFormat format = DateFormat('yyyy-MM-dd-HH:mm:ss');
    return format.format(this);
  }

  String get formattedDuration {
    if (isBefore(DateTime.now())) {
      return '$prettyDuration ago'.replaceFirst('-', '');
    } else {
      return 'in $prettyDuration';
    }
  }

  String get prettyDuration {
    final DateTime now = DateTime.now();
    final Duration dur = difference(
      DateTime(now.year, now.month, now.day, now.hour, now.minute),
    );
    return dur.pretty(
      tersity: DurationTersity.minute,
      maxUnits: 2,
      abbreviated: true,
    );
  }

  String get formattedHS {
    final String suffix = hour >= 12 ? 'PM' : 'AM';
    int hour12Base = hour % 12;
    hour12Base = hour12Base == 0 ? 12 : hour12Base;
    final String formattedTime =
        "$hour12Base:${minute.toString().padLeft(2, '0')} $suffix";
    return formattedTime;
  }
}
