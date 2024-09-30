import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/database/settings/swipe_actions.dart';
import 'package:Rem/reminder_class/reminder.dart';

final Map<String, dynamic> defaultSettings = {
  SettingOption.DueDateAddDuration.toString(): Duration(minutes: 5),

  SettingOption.RepeatIntervalFieldValue.toString(): Duration(minutes: 5), 
  SettingOption.RecurringIntervalFieldValue.toString(): RecurringIntervalExtension.getDisplayName(RecurringInterval.none), 

  SettingOption.QuickTimeSetOption1.toString(): DateTime(0, 0, 0, 9, 30, 0, 0, 0),
  SettingOption.QuickTimeSetOption2.toString(): DateTime(0, 0, 0, 12, 00, 0, 0, 0),
  SettingOption.QuickTimeSetOption3.toString(): DateTime(0, 0, 0, 18, 30, 0, 0, 0),
  SettingOption.QuickTimeSetOption4.toString(): DateTime(0, 0, 0, 22, 00, 0, 0, 0),

  SettingOption.QuickTimeEditOption1.toString(): Duration(minutes: 10),
  SettingOption.QuickTimeEditOption2.toString(): Duration(hours: 1),
  SettingOption.QuickTimeEditOption3.toString(): Duration(hours: 3),
  SettingOption.QuickTimeEditOption4.toString(): Duration(days: 1),
  SettingOption.QuickTimeEditOption5.toString(): Duration(minutes: -10),
  SettingOption.QuickTimeEditOption6.toString(): Duration(hours: -1),
  SettingOption.QuickTimeEditOption7.toString(): Duration(hours: -3),
  SettingOption.QuickTimeEditOption8.toString(): Duration(days: -1),

  SettingOption.RepeatIntervalOption1.toString(): Duration(minutes: 1),
  SettingOption.RepeatIntervalOption2.toString(): Duration(minutes: 5),
  SettingOption.RepeatIntervalOption3.toString(): Duration(minutes: 10),
  SettingOption.RepeatIntervalOption4.toString(): Duration(minutes: 15),
  SettingOption.RepeatIntervalOption5.toString(): Duration(minutes: 30),
  SettingOption.RepeatIntervalOption6.toString(): Duration(hours: 1),

  SettingOption.HomeTileSlideAction_ToLeft.toString(): SwipeAction.postpone.index,
  SettingOption.HomeTileSlideAction_ToRight.toString(): SwipeAction.delete.index,
  SettingOption.SlideActionPostponeDuration.toString(): Duration(minutes: 30),

  SettingOption.TextScale.toString(): 1.0
};