// Do not change the order of the enums. Buttons access 
// their respective values using the indexes.
import 'package:Rem/database/settings/swipe_actions.dart';

enum SettingOption {
  DueDateAddDuration, 
  RepeatIntervalFieldValue,
  RecurringIntervalFieldValue, // I think I should remove this, but would 
  // also have to make changes to wherever the enum's index is used. So..

  QuickTimeSetOption1, // Index 3 to 6
  QuickTimeSetOption2,
  QuickTimeSetOption3,
  QuickTimeSetOption4,

  QuickTimeEditOption1, // Index 7 to 14
  QuickTimeEditOption2,
  QuickTimeEditOption3,
  QuickTimeEditOption4,
  QuickTimeEditOption5,
  QuickTimeEditOption6,
  QuickTimeEditOption7,
  QuickTimeEditOption8,
  
  RepeatIntervalOption1, // Index 15 to 20
  RepeatIntervalOption2,
  RepeatIntervalOption3,
  RepeatIntervalOption4,
  RepeatIntervalOption5,
  RepeatIntervalOption6,

  HomeTileSlideAction_ToRight, // Index 21 to 24
  HomeTileSlideAction_ToLeft,
  SlideActionPostponeDuration,

  TextScale // Index 25
  // Don't forget to add new settings to [isValidtype] method.
}

class SettingsOptionMethods {
  
  // Using .toString for converting to String.

  static SettingOption fromString(String value) {
    try {
      return SettingOption.values.firstWhere(
        (option) => option.toString().toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      throw ArgumentError('Invalid setting option: $value');
    }
  }

  static bool isValidType(SettingOption option, dynamic value) {
    switch (option) {
      case SettingOption.RecurringIntervalFieldValue:
        return value is String;

      case SettingOption.QuickTimeSetOption1:
      case SettingOption.QuickTimeSetOption2:
      case SettingOption.QuickTimeSetOption3:
      case SettingOption.QuickTimeSetOption4:
        return value is DateTime;

      case SettingOption.DueDateAddDuration:
      case SettingOption.RepeatIntervalFieldValue:
      
      case SettingOption.QuickTimeEditOption1:
      case SettingOption.QuickTimeEditOption2:
      case SettingOption.QuickTimeEditOption3:
      case SettingOption.QuickTimeEditOption4:
      case SettingOption.QuickTimeEditOption5:
      case SettingOption.QuickTimeEditOption6:
      case SettingOption.QuickTimeEditOption7:
      case SettingOption.QuickTimeEditOption8:
            
      case SettingOption.RepeatIntervalOption1:
      case SettingOption.RepeatIntervalOption2:
      case SettingOption.RepeatIntervalOption3:
      case SettingOption.RepeatIntervalOption4:
      case SettingOption.RepeatIntervalOption5:
      case SettingOption.RepeatIntervalOption6:

      case SettingOption.SlideActionPostponeDuration:
        return value is Duration;

      case SettingOption.HomeTileSlideAction_ToLeft:
      case SettingOption.HomeTileSlideAction_ToRight:
        return value is SwipeAction;

      case SettingOption.TextScale:
        return value is double;
      
      default:
        throw ArgumentError('Unhandled SettingOption: $option');
    }
  }

  static SettingOption fromInt(int value) {
    return SettingOption.values[value];
  }

  static int getIndex(SettingOption option) {
    return option.index;
  }
}
