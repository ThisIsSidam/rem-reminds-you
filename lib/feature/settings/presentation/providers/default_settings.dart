import 'package:flutter/material.dart';

import 'settings_keys.dart';

final Map<SettingsKey, dynamic> defaultSettings = <SettingsKey, dynamic>{
  SettingsKey.defaultLeadDuration: const Duration(hours: 1),
  SettingsKey.defaultAutoSnoozeDuration: const Duration(minutes: 10),
  SettingsKey.quickTimeSetOption1: DateTime(0, 0, 0, 9, 30),
  SettingsKey.quickTimeSetOption2: DateTime(0, 0, 0, 12),
  SettingsKey.quickTimeSetOption3: DateTime(0, 0, 0, 18, 30),
  SettingsKey.quickTimeSetOption4: DateTime(0, 0, 0, 22),
  SettingsKey.quickTimeEditOption1: const Duration(minutes: 10),
  SettingsKey.quickTimeEditOption2: const Duration(hours: 1),
  SettingsKey.quickTimeEditOption3: const Duration(hours: 3),
  SettingsKey.quickTimeEditOption4: const Duration(days: 1),
  SettingsKey.quickTimeEditOption5: const Duration(minutes: -10),
  SettingsKey.quickTimeEditOption6: const Duration(hours: -1),
  SettingsKey.quickTimeEditOption7: const Duration(hours: -3),
  SettingsKey.quickTimeEditOption8: const Duration(days: -1),
  SettingsKey.autoSnoozeOption1: const Duration(minutes: 5),
  SettingsKey.autoSnoozeOption2: const Duration(minutes: 10),
  SettingsKey.autoSnoozeOption3: const Duration(minutes: 15),
  SettingsKey.autoSnoozeOption4: const Duration(minutes: 30),
  SettingsKey.autoSnoozeOption5: const Duration(hours: 1),
  SettingsKey.autoSnoozeOption6: const Duration(hours: 2),
  SettingsKey.homeTileSwipeActionLeft: 'Postpone',
  // SwipeAction.postpone.toString()
  SettingsKey.homeTileSwipeActionRight: 'Done/Delete',
  // SwipeAction.done.toString()
  SettingsKey.defaultPostponeDuration: const Duration(minutes: 30),
  SettingsKey.themeMode: 'system', // ThemeMode.system.toString()
  SettingsKey.noRushHoursStartTime: const TimeOfDay(hour: 7, minute: 0),
  SettingsKey.noRushHoursEndTime: const TimeOfDay(hour: 23, minute: 0),
  SettingsKey.textScale: 1.0,
};
