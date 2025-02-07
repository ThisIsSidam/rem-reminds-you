import 'package:hive_ce_flutter/hive_flutter.dart';

import '../enums/hive_enums.dart';

/// IndiValue Stores values that may even be unrelated to each
/// other that I just had to store for using them in the app.
/// The keys are the value names and the box just returns int values
/// instead of a key which stores a dictionary of key value pairs.
class UserDB {
  static final Box _box = Hive.box(HiveBoxNames.individualValues.name);

  static int? getNextId() {
    //TODO: Do something about keys
    return _box.get(HiveKeys.reminderIDGeneratorCurrentCountKey.key) as int;
  }

  static void setID(int value) {
    _box.put(HiveKeys.reminderIDGeneratorCurrentCountKey.key, value);
  }

  static String? getStoredAppVersion() {
    final dynamic version = _box.get('app_version');
    if (version != null && version is String) return version;
    return null;
  }

  static void storeAppVersion(String version) {
    _box.put('app_version', version);
  }
}
