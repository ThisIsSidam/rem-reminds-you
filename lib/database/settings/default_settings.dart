import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/reminder_class/reminder.dart';

final Map<String, dynamic> defaultSettings = {
  SettingOption.DueDateAddDuration.toString(): Duration(minutes: 12),

  SettingOption.RepeatIntervalFieldValue.toString(): Duration(minutes: 5), 
  SettingOption.RecurringIntervalFieldValue.toString(): RecurringIntervalExtension.getDisplayName(RecurringInterval.none), 

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

  SettingOption.RepeatIntervalOption1.toString(): Duration(minutes: 2),
  SettingOption.RepeatIntervalOption2.toString(): Duration(minutes: 6),
  SettingOption.RepeatIntervalOption3.toString(): Duration(minutes: 12),
  SettingOption.RepeatIntervalOption4.toString(): Duration(minutes: 17),
  SettingOption.RepeatIntervalOption5.toString(): Duration(minutes: 35),
  SettingOption.RepeatIntervalOption6.toString(): Duration(hours: 3),
};