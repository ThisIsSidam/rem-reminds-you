
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:Rem/reminder_class/reminder.dart';

class TitleParser {
  String originalTitle = ""; 
  Reminder thisReminder;
  final Function(bool) toggleParsedDateTimeField;
  final Function(Reminder) save;

  TitleParser({
    required this.thisReminder,
    required this.toggleParsedDateTimeField,
    required this.save 
  });
  
  void parse(String str) {
    originalTitle = str;
    final parseString = extractTitle(str);

    if(parseString != null)
    {
      if (!matchFinder(parseString))
      {
        originalTitle = originalTitle + parseString;
      }
      else
      {
        save(thisReminder); 
        toggleParsedDateTimeField(true);
        return;
      }
    }
    else
    {
      debugPrint("[TitleParserConstr] parseString null");
    }
    toggleParsedDateTimeField(false);

  }

  String? extractTitle(String str) {
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

  bool matchFinder(String str) {
    debugPrint("[matchFinder] '$str'");
    final durationRegExp = RegExp(r'in\s(\d+)\s+(minutes?|seconds?|hours?|days?)');
    final match1 = durationRegExp.firstMatch(str);
    if (match1 != null)
    {
      return parseDurationInput(match1);
    }
    else
    {
      debugPrint("[matchFinder] match1 null");
    }

    final timeRegExp = RegExp(r'(\d+:\d+)\s*(AM|am|PM|pm)?');

    final match2 = timeRegExp.firstMatch(str);
    if (match2 != null)
    {
      return parseDateTimeInput(match2);
    }
    else
    {
      debugPrint("[matchFinder] match2 null");
    }
    
    return false;
  }

  bool parseDurationInput(RegExpMatch match) {
    Duration toAdd = Duration();

    final value = int.parse(match.group(1)!);
    final unit = match.group(2);

    switch (unit) {
      case 'minutes':
      case 'minute':
      {
        toAdd += Duration(minutes: value);
      }
      case 'seconds':
      case 'second':
      {
        toAdd += Duration(seconds: value);
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
    thisReminder.updatedTime(DateTime.now().add(toAdd));
    return true;
  }

  bool parseDateTimeInput(RegExpMatch match) {
    

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

    thisReminder.updatedTime(DateTime(
      thisReminder.dateAndTime.year,
      thisReminder.dateAndTime.month,
      thisReminder.dateAndTime.day,
      hour,
      minute
    ));

    return true;
  }

}
