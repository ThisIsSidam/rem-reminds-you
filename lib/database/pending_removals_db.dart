import 'package:Rem/provider/reminders_provider.dart';
import 'package:Rem/utils/logger/global_logger.dart';
import 'package:hive/hive.dart';

import '../consts/enums/hive_enums.dart';

class PendingRemovalsDB {
  static final _box = Hive.box(HiveBoxNames.pendingRemovals.name);

  static List<int> getPendingRemovals() {
    if (!_box.isOpen) {
      Future(() {
        Hive.openBox(HiveBoxNames.reminders.name);
      });
    }

    return _box.get(HiveKeys.pendingRemovalsBoxKey.key)?.cast<int>() ?? [];
  }

  static Future<void> addPendingRemoval(int id) async {
    final List<int> removals = getPendingRemovals();
    removals.add(id);
    _box.put(HiveKeys.pendingRemovalsBoxKey.key, removals);
    gLogger.i('Added reminder to pendingRemovals | ID : $id');
  }

  static Future<void> clearPendingRemovals() async {
    final removals = getPendingRemovals();
    for (final id in removals) {
      RemindersNotifier(ref: null).markAsDone(id);
      gLogger.i('Cleared Pending Removals | Len : ${removals.length}');
    }
    _box.put(HiveKeys.pendingRemovalsBoxKey.key, []);
  }
}
