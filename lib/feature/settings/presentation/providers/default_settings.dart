import 'package:flutter/material.dart';

final Map<String, dynamic> defaultSettings = {
  'defaultLeadDuration': Duration(hours: 1),
  'defaultAutoSnoozeDuration': Duration(minutes: 15),
  'recurringIntervalFieldValue': 'none', // RecurringInterval.none.toString()
  'quickTimeSetOption1': DateTime(0, 0, 0, 9, 30, 0, 0, 0),
  'quickTimeSetOption2': DateTime(0, 0, 0, 12, 0, 0, 0),
  'quickTimeSetOption3': DateTime(0, 0, 0, 18, 30, 0, 0, 0),
  'quickTimeSetOption4': DateTime(0, 0, 0, 22, 0, 0, 0),
  'quickTimeEditOption1': Duration(minutes: 10),
  'quickTimeEditOption2': Duration(hours: 1),
  'quickTimeEditOption3': Duration(hours: 3),
  'quickTimeEditOption4': Duration(days: 1),
  'quickTimeEditOption5': Duration(minutes: -10),
  'quickTimeEditOption6': Duration(hours: -1),
  'quickTimeEditOption7': Duration(hours: -3),
  'quickTimeEditOption8': Duration(days: -1),
  'autoSnoozeOption1': Duration(minutes: 5),
  'autoSnoozeOption2': Duration(minutes: 10),
  'autoSnoozeOption3': Duration(minutes: 15),
  'autoSnoozeOption4': Duration(minutes: 30),
  'autoSnoozeOption5': Duration(hours: 1),
  'autoSnoozeOption6': Duration(hours: 2),
  'homeTileSwipeActionLeft': 'postpone', // SwipeAction.postpone.toString()
  'homeTileSwipeActionRight': 'done', // SwipeAction.done.toString()
  'defaultPostponeDuration': Duration(minutes: 30),
  'themeMode': 'system', // ThemeMode.system.toString()
  'quietHoursStartTime': TimeOfDay(hour: 23, minute: 0),
  'quietHoursEndTime': TimeOfDay(hour: 7, minute: 0),
  'textScale': 1.0,
};
