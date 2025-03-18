import 'dart:convert';

import 'package:objectbox/objectbox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/entities/no_rush_entitiy/no_rush_entity.dart';
import '../../../../core/data/entities/reminder_entitiy/reminder_entity.dart';
import '../../../../core/data/models/no_rush_reminder/no_rush_reminder.dart';
import '../../../../core/data/models/reminder/reminder.dart';
import '../../../../core/providers/global_providers.dart';
import '../../../../core/services/notification_service/notification_service.dart';

part 'generated/reminders_repo.g.dart';

@riverpod
class RemindersRepository extends _$RemindersRepository {
  late Box<ReminderEntity> _box;

  @override
  List<ReminderEntity> build() {
    final Store store = ref.watch(objectboxStoreProvider);
    _box = store.box<ReminderEntity>();
    _startListeners();
    return _box.query().build().find();
  }

  void _startListeners() {
    _box
        .query()
        .watch(triggerImmediately: true)
        .map((Query<ReminderEntity> v) => v.find())
        .listen((List<ReminderEntity> v) => state = v);
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

  String getBackup() {
    final List<Map<String, dynamic>> jsonData =
        state.map((ReminderEntity e) => e.toJson()).toList();
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
        await NotificationController.scheduleNotification(
          r.toModel.copyWith(id: id),
        );
      }
    }
    return true;
  }
}

@riverpod
class NoRushRemindersRepository extends _$NoRushRemindersRepository {
  late Box<NoRushReminderEntity> _box;

  @override
  List<NoRushReminderEntity> build() {
    final Store store = ref.watch(objectboxStoreProvider);
    _box = store.box<NoRushReminderEntity>();
    _startListeners();
    return _box.query().build().find();
  }

  void _startListeners() {
    _box
        .query()
        .watch(triggerImmediately: true)
        .map((Query<NoRushReminderEntity> v) => v.find())
        .listen((List<NoRushReminderEntity> v) => state = v);
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

  String getBackup() {
    final List<Map<String, dynamic>> jsonData =
        state.map((NoRushReminderEntity e) => e.toJson()).toList();
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

      await NotificationController.scheduleNotification(
        r.toModel.copyWith(id: id),
      );
    }
    return true;
  }
}
