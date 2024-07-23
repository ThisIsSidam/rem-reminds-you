import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/reminder_class/reminder.dart';

final Map<String, dynamic> defaultSettings = {
  SettingOption.DueDateAddDuration.toString(): Duration(minutes: 12),

  SettingOption.RepeatInterval.toString(): Duration(minutes: 5), 
  SettingOption.RecurringInterval.toString(): RecurringIntervalExtension.getDisplayName(RecurringInterval.none), 

  SettingOption.QuickTimeSetOption1.toString(): DateTime(0, 0, 0, 11, 30, 0, 0, 0),
  SettingOption.QuickTimeSetOption2.toString(): DateTime(0, 0, 0, 13, 00, 0, 0, 0),
  SettingOption.QuickTimeSetOption3.toString(): DateTime(0, 0, 0, 19, 30, 0, 0, 0),
  SettingOption.QuickTimeSetOption4.toString(): DateTime(0, 0, 0, 9, 00, 0, 0, 0),

  SettingOption.QuickTimeEditOption1.toString(): Duration(minutes: 30),
  SettingOption.QuickTimeEditOption2.toString(): Duration(hours: 4),
  SettingOption.QuickTimeEditOption3.toString(): Duration(hours: 6),
  SettingOption.QuickTimeEditOption4.toString(): Duration(days: 2),
  SettingOption.QuickTimeEditOption5.toString(): Duration(minutes: -20),
  SettingOption.QuickTimeEditOption6.toString(): Duration(hours: -1),
  SettingOption.QuickTimeEditOption7.toString(): Duration(hours: -3),
  SettingOption.QuickTimeEditOption8.toString(): Duration(days: -1),
};