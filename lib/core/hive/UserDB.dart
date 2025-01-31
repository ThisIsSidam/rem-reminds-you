import 'package:Rem/core/enums/hive_enums.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// IndiValue Stores values that may even be unrelated to each
/// other that I just had to store for using them in the app.
/// The keys are the value names and the box just returns int values
/// instead of a key which stores a dictionary of key value pairs.
class UserDB {
  static final _box = Hive.box(HiveBoxNames.individualValues.name);

  static int? getNextId() {
    //TODO: Do something about keys
    return _box.get(HiveKeys.reminderIDGeneratorCurrentCountKey.key);
  }

  static void setID(int value) {
    _box.put(HiveKeys.reminderIDGeneratorCurrentCountKey.key, value);
  }

  static String? getStoredAppVersion() {
    return _box.get('app_version');
  }

  static void storeAppVersion(String version) {
    _box.put('app_version', version);
  }
}
