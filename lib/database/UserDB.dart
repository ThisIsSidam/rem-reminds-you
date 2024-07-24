import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/settings/default_settings.dart';
import 'package:Rem/database/settings/settings_enum.dart';
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

  static dynamic getSetting(SettingOption option) {

    var value = _box.get(option.toString());
    if (value == null)
    {
      value = defaultSettings[option.toString()];
      _box.put(option.toString(), value);
    }
    return value;
  }

  static void setSetting(SettingOption option, dynamic value) {
    if (!SettingsOptionMethods.isValidType(option, value)) {
      throw ArgumentError("[setSetting] Value doesn't match the type of the option");
    }

    _box.put(option.toString(), value);
  }
}