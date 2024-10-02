import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TitleParseHandler {
  WidgetRef ref;
  late Reminder thisReminder;
  late DateTime originalDT;

  TitleParseHandler({
    required this.ref,
  }){
    this.thisReminder = ref.read(reminderNotifierProvider);
    this.originalDT = thisReminder.dateAndTime;
  }
  
  void parse(String str) {
    thisReminder.preParsedTitle = str;
    final parsedString = extractDateTimeString(str);

    if(parsedString != null)
    {
      final parsedDateTime = getParsedDateTime(parsedString);
      if (parsedDateTime != null)
      {
        thisReminder.updatedTime(parsedDateTime);
      }
      else 
      {
        thisReminder.dateAndTime = originalDT;
      }
    }
    else
    {
      thisReminder.title = str;
    }
    ref.read(reminderNotifierProvider.notifier).updateReminder(thisReminder);
  }


  /// Extracts the [DateTime] or [Duration] string.
  String? extractDateTimeString(String str) {
    final inIndex = str.lastIndexOf(' in ');
    final atIndex = str.lastIndexOf(' at ');

    if (inIndex == -1 && atIndex == -1) {
      thisReminder.title = str;
    }

    final separatorIndex = (inIndex > atIndex && inIndex != -1) ? inIndex : atIndex;

    if (separatorIndex == -1) {
      return null;
    }
    
    thisReminder.title = str.substring(0, separatorIndex).trim();
    
    String parseString = str.substring(separatorIndex).trim();
    return parseString;
  }


  /// Extracts the [DateTime] object from the [DateTime] string.
  DateTime? getParsedDateTime(String str) {
    final durationRegExp = RegExp(r'in\s(\d+)\s+(minutes?|hours?|days?)');
    final match1 = durationRegExp.firstMatch(str);
    if (match1 != null)
    {
      return parseDurationInput(match1);
    }

    final timeRegExp = RegExp(r'(\d+:\d+)\s*(AM|am|PM|pm)?');

    final match2 = timeRegExp.firstMatch(str);
    if (match2 != null)
    {
      return parseDateTimeInput(match2);
    }
    
    return null;
  }

  /// Extracts [Duration] object from string, adds it to [DateTime.now()] and
  /// returns the [DateTime].
  DateTime parseDurationInput(RegExpMatch match) {
    Duration toAdd = Duration();

    final value = int.parse(match.group(1)!);
    final unit = match.group(2);

    switch (unit) {
      case 'minutes':
      case 'minute':
      {
        toAdd += Duration(minutes: value);
      }
      case 'hours':
      case 'hour':
      {
        toAdd += Duration(hours: value);
      }
      case 'days':
      case 'day':
      {
        toAdd += Duration(days: value);
      }
    }

    return DateTime.now().add(toAdd);
  }

  /// Extracts and returns [DateTime] object from string.
  DateTime parseDateTimeInput(RegExpMatch match) {

    final timeString = match.group(1) ?? "0:0";
    final amPm = match.group(2);

    List<String> timeParts = timeString.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    if (amPm != null) {
      if (amPm.toUpperCase() == 'PM') {
        hour = (hour == 12) ? 12 : hour + 12;
      } else {
        hour = (hour == 12) ? 0 : hour;
      }
    }

    return DateTime(
      thisReminder.dateAndTime.year,
      thisReminder.dateAndTime.month,
      thisReminder.dateAndTime.day,
      hour,
      minute
    );
  }

}
