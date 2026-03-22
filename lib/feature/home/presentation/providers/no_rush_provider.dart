// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/constants/const_strings.dart';
import '../../../../core/data/entities/no_rush_entitiy/no_rush_entity.dart';
import '../../../../core/data/models/no_rush_reminder.dart';
import '../../../../core/data/models/reminder_base.dart';
import '../../../../core/services/notification_service/notification_service.dart';
import '../../../../main.dart';
import '../../../../shared/utils/id_handler.dart';
import '../../../../shared/utils/logger/app_logger.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/repositories/reminders_repo.dart';
import 'reminders_provider.dart';

part 'generated/no_rush_provider.g.dart';

@riverpod
class NoRushRemindersNotifier extends _$NoRushRemindersNotifier {
  final NoRushRemindersRepository _repo = getIt<NoRushRemindersRepository>();
  StreamSubscription<List<NoRushReminderEntity>>? _noRushSubscription;

  @override
  List<NoRushReminderModel> build() {
    _handleEntitiesStream();

    // Handle dispose
    ref.onDispose(() => _noRushSubscription?.cancel());

    AppLogger.i('RemindersNotifier initialized');
    return <NoRushReminderModel>[];
  }

  void _handleEntitiesStream() {
    _noRushSubscription = _repo
        .getRemindersStream()
        .listen((List<NoRushReminderEntity> entities) {
      state = entities.map((NoRushReminderEntity val) => val.toModel).toList();
    });
  }

  bool isEmpty() => state.isEmpty;

  Future<NoRushReminderModel> saveReminder(NoRushReminderModel reminder) async {
    if (reminder.id != newReminderID) {
      await NotificationController.cancelScheduledNotification(
        IdHandler().getGroupKey(reminder),
      );
    }
    final int id = _repo.saveReminder(reminder.toEntity);

    await NotificationController.scheduleNotification(
      reminder.copyWith(id: id),
    );

    AppLogger.i('Saved Reminder in Database | ID: $id');
    return reminder;
  }

  Future<bool> deleteReminder(int id) async {
    final NoRushReminderModel? reminder = _repo.getReminder(id);
    if (reminder == null) {
      AppLogger.i('Reminder not found | Cannot perform action.');
      return false;
    }
    await NotificationController.cancelScheduledNotification(
      IdHandler().getGroupKey(
        reminder,
      ),
    );

    final bool removed = _repo.removeReminder(id);
    AppLogger.i('Deleted reminder from database | ID: $id | Status: $removed');
    return removed;
  }

  Future<void> postponeReminder(NoRushReminderModel reminder) async =>
      saveReminder(reminder.copyWith(dateTime: _getRandomTime()));

  /// Takes a [ReminderBase] instance, turns it into a [NoRushReminderModel],
  /// and saves it.
  Future<void> moveReminder(ReminderBase reminder) async {
    // Get notifier instance beforehand since we can't after making a
    // state change using saveReminder call
    final RemindersNotifier remindersNotifier =
        ref.read(remindersNotifierProvider.notifier);

    // Create new NoRush reminder based on normal reminder instance
    await saveReminder(
      NoRushReminderModel(
        id: 0,
        title: reminder.title,
        autoSnoozeInterval: reminder.autoSnoozeInterval,
        dateTime: _getRandomTime(),
      ),
    );

    // Delete normal reminder after no-rush version is saved.
    // To be done because both are stored in different boxes and would cause
    // duplicates if original is not deleted.
    await remindersNotifier.deleteReminder(reminder.id);
  }

  // -------------------------
  // --- BACKUP & RESTORE -------------------------
  // -------------------------

  Future<String> getBackup() async {
    final String backup = _repo.getBackup();
    AppLogger.i('Created Database Backup');
    return backup;
  }

  Future<void> restoreBackup(String jsonData) async {
    await _repo.restoreBackup(jsonData);
    AppLogger.i('Restored Database Backup');
  }

  // -------------------------
  // --- HELPERS -------------------------
  // -------------------------

  DateTime _getRandomTime() {
    final UserSettingsNotifier settings = ref.read(userSettingsProvider);
    final TimeOfDay startTime = settings.noRushStartTime;
    final TimeOfDay endTime = settings.noRushEndTime;
    return NoRushReminderModel.generateRandomFutureTime(startTime, endTime);
  }
}
