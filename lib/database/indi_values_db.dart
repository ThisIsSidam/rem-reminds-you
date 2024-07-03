import 'package:Rem/consts/consts.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// IndiValue Stores values that may even be unrelated to each 
/// other that I just had to store for using them in the app.
/// The keys are the value names and the box just returns int values
/// instead of a key which stores a dictionary of key value pairs.
class IndiValuesDb {
  static final _box = Hive.box(indiValuesBoxName);

  static int? getIndiValue(String key) {
    return _box.get(key);
  }

  static void setIndiValue(String key, int value) {
    _box.put(key, value);
  }
}