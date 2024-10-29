import 'package:hive_flutter/hive_flutter.dart';

import '../consts/enums/hive_box_names.dart';

class SettingsDB {
  static final _box = Hive.box(HiveBoxNames.settings.name);

  static dynamic getUserSetting(String key) {
    return _box.get(key);
  }

  static void setUserSetting(String key, dynamic value) {
    _box.put(key, value);
  }
}
