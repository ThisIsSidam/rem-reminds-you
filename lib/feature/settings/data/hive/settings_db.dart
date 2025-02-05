import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../../core/enums/hive_enums.dart';

class SettingsDB {
  static final _box = Hive.box(HiveBoxNames.settings.name);

  static dynamic getUserSetting(String key) {
    return _box.get(key);
  }

  static void setUserSetting(String key, dynamic value) {
    _box.put(key, value);
  }
}
