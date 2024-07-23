enum SettingOption {
  DueDateAddDuration, 
  RepeatInterval,
  RecurringInterval,
  QuickTimeSetOption1, 
  QuickTimeSetOption2,
  QuickTimeSetOption3,
  QuickTimeSetOption4,
  QuickTimeEditOption1,
  QuickTimeEditOption2,
  QuickTimeEditOption3,
  QuickTimeEditOption4,
  QuickTimeEditOption5,
  QuickTimeEditOption6,
  QuickTimeEditOption7,
  QuickTimeEditOption8,
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

  static SettingOption fromInt(int value) {
    return SettingOption.values[value];
  }

  static int getIndex(SettingOption option) {
    return option.index;
  }
}
