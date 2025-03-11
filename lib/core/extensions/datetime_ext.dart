import 'package:duration/duration.dart';
import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String friendly({bool is24Hour = false}) {
    final DateFormat format = is24Hour
        ? DateFormat('EEE, d MMM, HH:mm')
        : DateFormat('EEE, d MMM, hh:mm aaa');
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

  String formattedHM({bool is24Hour = false}) {
    if (is24Hour) {
      // ignore: lines_longer_than_80_chars
      return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    } else {
      final String suffix = hour >= 12 ? 'PM' : 'AM';
      int hour12Base = hour % 12;
      hour12Base = hour12Base == 0 ? 12 : hour12Base;
      return "$hour12Base:${minute.toString().padLeft(2, '0')} $suffix";
    }
  }
}
