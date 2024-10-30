import 'package:Rem/provider/reminders_provider.dart';
import 'package:flutter/material.dart';
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
    final removals = getPendingRemovals();
    removals.add(id);
    _box.put(HiveKeys.pendingRemovalsBoxKey.key, removals);
  }

  static Future<void> clearPendingRemovals() async {
    final removals = getPendingRemovals();
    for (final id in removals) {
      RemindersNotifier(ref: null).markAsDone(id);
      debugPrint('[clearPendingRemovals] id: $id');
    }
    _box.put(HiveKeys.pendingRemovalsBoxKey.key, []);
  }
}
