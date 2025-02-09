import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/utils/logger/global_logger.dart';
import '../enums/storage_enums.dart';

class PendingRemovalsDB {
  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  static Future<List<int>> getPendingRemovals() async {
    final SharedPreferences prefs = await _prefs;
    return prefs
            .getStringList(SharedKeys.pendingRemovals.key)
            ?.map((String e) => int.tryParse(e) ?? -1)
            .toList() ??
        <int>[];
  }

  static Future<void> addPendingRemoval(int id) async {
    final SharedPreferences prefs = await _prefs;
    final List<int> removals = await getPendingRemovals()
      ..add(id);
    await prefs.setStringList(
      SharedKeys.pendingRemovals.key,
      removals.map((int e) => e.toString()).toList(),
    );
    gLogger.i('Added reminder to pendingRemovals | ID : $id');
  }

  static Future<List<int>> clearPendingRemovals() async {
    final SharedPreferences prefs = await _prefs;
    final List<int> removals = await getPendingRemovals();
    await prefs.setStringList(SharedKeys.pendingRemovals.key, <String>[]);
    return removals;
  }
}
