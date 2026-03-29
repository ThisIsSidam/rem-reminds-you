import 'dart:convert';

import 'package:objectbox/objectbox.dart';

import '../../../../core/services/notification_service/notification_service.dart';
import '../entities/no_rush_entity.dart';
import '../entities/reminder_entity.dart';
import '../models/no_rush_reminder.dart';
import '../models/reminder.dart';

/// Repository which handles CRUD Operatioins to [ReminderEntity] box.
class RemindersRepository {
  RemindersRepository(Store store) : _box = store.box<ReminderEntity>();

  /// The [Box] handling all database operations of [ReminderEntity].
  late final Box<ReminderEntity> _box;

  /// Returns a stream of [ReminderEntity].
  Stream<List<ReminderEntity>> getRemindersStream() {
    return _box
        .query()
        .watch(triggerImmediately: true)
        .map((Query<ReminderEntity> v) => v.find());
  }

  int saveReminder(ReminderEntity entity) {
    return _box.put(entity);
  }

  ReminderModel? getReminder(int id) {
    return _box.get(id)?.toModel;
  }

  bool removeReminder(int id) {
    return _box.remove(id);
  }

  // ----------------------------
  // ----- BACKUP & RESTORE -------------------
  // ----------------------------

  String getBackup() {
    final List<ReminderEntity> reminders = _box.query().build().find();
    final List<Map<String, dynamic>> jsonData = reminders
        .map((ReminderEntity e) => e.toJson())
        .toList();
    return jsonEncode(<String, Object>{
      'reminders': jsonData,
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0',
    });
  }

  Future<bool> restoreBackup(String json) async {
    final Map<String, dynamic> decoded =
        jsonDecode(json) as Map<String, dynamic>;
    final List<Map<String, dynamic>> remindersData =
        (decoded['reminders'] as List<dynamic>).cast<Map<String, dynamic>>();
    final List<ReminderEntity> reminders = remindersData
        .map(
          (Map<String, dynamic> e) => ReminderEntity.fromJson(e, asNew: true),
        )
        .toList();
    for (final ReminderEntity r in reminders) {
      final int id = saveReminder(r);

      if (!r.paused) {
        // Only reschedule if reminder is NOT paused
        await NotificationService.scheduleReminder(r.toModel.copyWith(id: id));
      }
    }
    return true;
  }
}

/// Repository which handles CRUD Operatioins to [NoRushReminderEntity] box.
class NoRushRemindersRepository {
  NoRushRemindersRepository(Store store)
    : _box = store.box<NoRushReminderEntity>();

  /// The [Box] handling all database operations of [NoRushReminderEntity].
  late final Box<NoRushReminderEntity> _box;

  /// Returns a stream of [NoRushReminderEntity].
  Stream<List<NoRushReminderEntity>> getRemindersStream() {
    return _box
        .query()
        .watch(triggerImmediately: true)
        .map((Query<NoRushReminderEntity> v) => v.find());
  }

  int saveReminder(NoRushReminderEntity entity) {
    return _box.put(entity);
  }

  NoRushReminderModel? getReminder(int id) {
    return _box.get(id)?.toModel;
  }

  bool removeReminder(int id) {
    return _box.remove(id);
  }

  // ----------------------------
  // ----- BACKUP & RESTORE -------------------
  // ----------------------------

  String getBackup() {
    final List<NoRushReminderEntity> allNoRush = _box.query().build().find();
    final List<Map<String, dynamic>> jsonData = allNoRush
        .map((NoRushReminderEntity e) => e.toJson())
        .toList();
    return jsonEncode(<String, Object>{
      'reminders': jsonData,
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0',
    });
  }

  Future<bool> restoreBackup(String json) async {
    final Map<String, dynamic> decoded =
        jsonDecode(json) as Map<String, dynamic>;
    final List<Map<String, dynamic>> remindersData =
        (decoded['reminders'] as List<dynamic>).cast<Map<String, dynamic>>();
    final List<NoRushReminderEntity> reminders = remindersData
        .map(
          (Map<String, dynamic> e) =>
              NoRushReminderEntity.fromJson(e, asNew: true),
        )
        .toList();
    for (final NoRushReminderEntity r in reminders) {
      final int id = saveReminder(r);

      await NotificationService.scheduleReminder(r.toModel.copyWith(id: id));
    }
    return true;
  }
}
