import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../feature/home/presentation/providers/reminders_provider.dart';
import '../../shared/utils/logger/global_logger.dart';
import '../enums/hive_enums.dart';

class PendingRemovalsDB {
  static final Box _box = Hive.box(HiveBoxNames.pendingRemovals.name);

  static List<int> getPendingRemovals() {
    if (!_box.isOpen) {
      Future<void>(() {
        Hive.openBox(HiveBoxNames.reminders.name);
      });
    }

    return _box.get(HiveKeys.pendingRemovalsBoxKey.key)?.cast<int>()
            as List<int>? ??
        <int>[];
  }

  static Future<void> addPendingRemoval(int id) async {
    final List<int> removals = getPendingRemovals()..add(id);
    await _box.put(HiveKeys.pendingRemovalsBoxKey.key, removals);
    gLogger.i('Added reminder to pendingRemovals | ID : $id');
  }

  static Future<void> clearPendingRemovals() async {
    final List<int> removals = getPendingRemovals();
    for (final int id in removals) {
      await RemindersNotifier().markAsDone(id);
      gLogger.i('Cleared Pending Removals | Len : ${removals.length}');
    }
    await _box.put(HiveKeys.pendingRemovalsBoxKey.key, <int>[]);
  }
}
