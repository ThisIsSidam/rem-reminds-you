import 'package:flutter/material.dart';

final Map<String, dynamic> defaultSettings = <String, dynamic>{
  'defaultLeadDuration': const Duration(hours: 1),
  'defaultAutoSnoozeDuration': const Duration(minutes: 10),
  'recurringIntervalFieldValue': 'none', // RecurringInterval.none.toString()
  'quickTimeSetOption1': DateTime(0, 0, 0, 9, 30),
  'quickTimeSetOption2': DateTime(0, 0, 0, 12),
  'quickTimeSetOption3': DateTime(0, 0, 0, 18, 30),
  'quickTimeSetOption4': DateTime(0, 0, 0, 22),
  'quickTimeEditOption1': const Duration(minutes: 10),
  'quickTimeEditOption2': const Duration(hours: 1),
  'quickTimeEditOption3': const Duration(hours: 3),
  'quickTimeEditOption4': const Duration(days: 1),
  'quickTimeEditOption5': const Duration(minutes: -10),
  'quickTimeEditOption6': const Duration(hours: -1),
  'quickTimeEditOption7': const Duration(hours: -3),
  'quickTimeEditOption8': const Duration(days: -1),
  'autoSnoozeOption1': const Duration(minutes: 5),
  'autoSnoozeOption2': const Duration(minutes: 10),
  'autoSnoozeOption3': const Duration(minutes: 15),
  'autoSnoozeOption4': const Duration(minutes: 30),
  'autoSnoozeOption5': const Duration(hours: 1),
  'autoSnoozeOption6': const Duration(hours: 2),
  'homeTileSwipeActionLeft': 'Postpone', // SwipeAction.postpone.toString()
  'homeTileSwipeActionRight': 'Done/Delete', // SwipeAction.done.toString()
  'defaultPostponeDuration': const Duration(minutes: 30),
  'themeMode': 'system', // ThemeMode.system.toString()
  'noRushHoursStartTime': const TimeOfDay(hour: 7, minute: 0),
  'noRushHoursEndTime': const TimeOfDay(hour: 23, minute: 0),
  'textScale': 1.0,
};
