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
  final durationRegExp = RegExp(r'in\s(\d+)\s*(m(?:in(?:ute)?s?)?|h(?:(?:ou)?rs?)?|d(?:ays?)?)');
  final match1 = durationRegExp.firstMatch(str);
  if (match1 != null) {
    return parseDurationInput(match1);
  }

  final timeRegExp = RegExp(r'(?:at\s*)?(\d{1,2})(?::(\d{1,2}))?\s*((?:a|p)\.?m?\.?)?', caseSensitive: false);
  final match2 = timeRegExp.firstMatch(str);
  if (match2 != null) {
    return parseDateTimeInput(match2);
  }
  
  return null;
}

/// Extracts [Duration] object from string, adds it to [DateTime.now()] and
/// returns the [DateTime].
DateTime parseDurationInput(RegExpMatch match) {
  final value = int.parse(match.group(1)!);
  final unit = match.group(2)!.toLowerCase();

  Duration toAdd;
  if (unit.startsWith('m')) {
    toAdd = Duration(minutes: value);
  } else if (unit.startsWith('h')) {
    toAdd = Duration(hours: value);
  } else if (unit.startsWith('d')) {
    toAdd = Duration(days: value);
  } else {
    throw FormatException('Unrecognized time unit: $unit');
  }

  return DateTime.now().add(toAdd);
}

/// Extracts and returns [DateTime] object from string.
DateTime parseDateTimeInput(RegExpMatch match) {
  int hour = int.parse(match.group(1)!);
  int minute = int.tryParse(match.group(2) ?? '0') ?? 0;
  String? amPm = match.group(3)?.toLowerCase();

  if (amPm != null) {
    if (amPm.startsWith('p') && hour != 12) {
      hour += 12;
    } else if (amPm.startsWith('a') && hour == 12) {
      hour = 0;
    }
  }

  final now = DateTime.now();
  var dateTime = DateTime(
    thisReminder.dateAndTime.year,
    thisReminder.dateAndTime.month,
    thisReminder.dateAndTime.day,
    hour,
    minute
  );

  // If the parsed time is earlier than the current time, assume it's for tomorrow
  if (dateTime.isBefore(now)) {
    dateTime = dateTime.add(const Duration(days: 1));
  }

  return dateTime;
}

}
