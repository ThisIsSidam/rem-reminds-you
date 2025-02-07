import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/sheet_reminder_notifier.dart';

class TitleParseHandler {
  TitleParseHandler({
    required this.ref,
  }) {
    dateTime = ref.read(sheetReminderNotifier).dateTime;
    originalDT = dateTime;
  }
  WidgetRef ref;
  late DateTime originalDT;
  late DateTime dateTime;

  void parse(String str) {
    final SheetReminderNotifier reminderNotifier =
        ref.read(sheetReminderNotifier.notifier);
    final (String, String)? extractedStrings = extractDateTimeString(str);

    if (extractedStrings != null) {
      reminderNotifier.updateTitle(extractedStrings.$1);
      final DateTime? parsedDateTime = getParsedDateTime(extractedStrings.$2);
      if (parsedDateTime != null) {
        dateTime = moveTimeIfNeeded(parsedDateTime);
      } else {
        dateTime = originalDT;
      }
    } else {
      reminderNotifier.updateTitle(str);
    }
    reminderNotifier.updateDateTime(dateTime);
  }

  /// Extracts the [DateTime] or [Duration] string.
  (String, String)? extractDateTimeString(String str) {
    final int inIndex = str.lastIndexOf(' in ');
    final int atIndex = str.lastIndexOf(' at ');

    final int separatorIndex =
        (inIndex > atIndex && inIndex != -1) ? inIndex : atIndex;

    if (separatorIndex == -1) {
      return null;
    }

    return (
      str.substring(0, separatorIndex).trim(),
      str.substring(separatorIndex).trim()
    );
  }

  /// Extracts the [DateTime] object from the [DateTime] string.
  DateTime? getParsedDateTime(String str) {
    final RegExp durationRegExp =
        RegExp(r'in\s(\d+)\s*(m(?:in(?:ute)?s?)?|h(?:(?:ou)?rs?)?|d(?:ays?)?)');
    final RegExpMatch? match1 = durationRegExp.firstMatch(str);
    if (match1 != null) {
      return parseDurationInput(match1);
    }

    final RegExp timeRegExp = RegExp(
      r'(?:at\s*)?(\d{1,2})(?::(\d{1,2}))?\s*((?:a|p)\.?m?\.?)?',
      caseSensitive: false,
    );
    final RegExpMatch? match2 = timeRegExp.firstMatch(str);
    if (match2 != null) {
      return parseDateTimeInput(match2);
    }

    return null;
  }

  /// Extracts [Duration] object from string, adds it to [DateTime.now()] and
  /// returns the [DateTime].
  DateTime parseDurationInput(RegExpMatch match) {
    final int value = int.parse(match.group(1)!);
    final String unit = match.group(2)!.toLowerCase();

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
    final int minute = int.tryParse(match.group(2) ?? '0') ?? 0;
    final String? amPm = match.group(3)?.toLowerCase();

    if (amPm != null) {
      if (amPm.startsWith('p') && hour != 12) {
        hour += 12;
      } else if (amPm.startsWith('a') && hour == 12) {
        hour = 0;
      }
    }

    final DateTime now = DateTime.now();
    DateTime newDT = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      hour,
      minute,
    );

    // If the parsed time is earlier than the current time,
    // assume it's for tomorrow
    if (newDT.isBefore(now)) {
      newDT = newDT.add(const Duration(days: 1));
    }

    return newDT;
  }

  /// If the time to be updated is in the past, increase it by a day.
  DateTime moveTimeIfNeeded(DateTime updatedTime) {
    late final DateTime movedTime;
    if (updatedTime.isBefore(DateTime.now())) {
      movedTime = updatedTime.add(const Duration(days: 1));
    }
    return DateTime(
      // Seconds should be 0
      movedTime.year,
      movedTime.month,
      movedTime.day,
      movedTime.hour,
      movedTime.minute,
    );
  }
}
