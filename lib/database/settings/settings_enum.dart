// Do not change the order of the enums. Buttons access 
// their respective values using the indexes.
enum SettingOption {
  DueDateAddDuration, 
  RepeatIntervalFieldValue,
  RecurringIntervalFieldValue,

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
