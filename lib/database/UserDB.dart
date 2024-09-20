import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/settings/default_settings.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/database/settings/swipe_actions.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// IndiValue Stores values that may even be unrelated to each
/// other that I just had to store for using them in the app.
/// The keys are the value names and the box just returns int values
/// instead of a key which stores a dictionary of key value pairs.
class UserDB {
  static final _box = Hive.box(indiValuesBoxName);

  static int? getIndiValue(String key) {
    return _box.get(key);
  }

  static void setIndiValue(String key, int value) {
    _box.put(key, value);
  }

  // Settings Section ----------------------------------------------------------------------------

  static dynamic getSetting(SettingOption option) {
    var value = _box.get(option.toString());
    if (value == null) {
      value = defaultSettings[option.toString()];
      _box.put(option.toString(), value);
    }

    if (option == SettingOption.HomeTileSlideAction_ToLeft ||
        option == SettingOption.HomeTileSlideAction_ToRight) {
      return SwipeAction.fromIndex(value);
    }
    return value;
  }

  static void setSetting(SettingOption option, dynamic value) {
    if (!SettingsOptionMethods.isValidType(option, value)) {
      throw ArgumentError(
          "[setSetting] Value doesn't match the type of the option");
    }

    if (value is SwipeAction) {
      _box.put(option.toString(), value.index);
      return;
    }

    _box.put(option.toString(), value);
  }

  static void resetSetting() {
    for (var option in defaultSettings.keys) {
      _box.put(option, defaultSettings[option]);
    }
  }
}
