// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/const_strings.dart';
import '../../../../core/data/entities/no_rush_entitiy/no_rush_entity.dart';
import '../../../../core/data/models/no_rush_reminder/no_rush_reminder.dart';
import '../../../../core/services/notification_service/notification_service.dart';
import '../../../../main.dart';
import '../../../../shared/utils/id_handler.dart';
import '../../../../shared/utils/logger/global_logger.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/repositories/reminders_repo.dart';

part 'generated/no_rush_provider.g.dart';

@riverpod
class NoRushRemindersNotifier extends _$NoRushRemindersNotifier {
  bool isEmpty = true;

  final NoRushRemindersRepository _repo = getIt<NoRushRemindersRepository>();
  StreamSubscription<List<NoRushReminderEntity>>? _noRushSubscription;

  @override
  List<NoRushReminderModel> build() {
    _handleEntitiesStream();

    // Handle dispose
    ref.onDispose(() => _noRushSubscription?.cancel());

    gLogger.i('RemindersNotifier initialized');
    return <NoRushReminderModel>[];
  }

  void _handleEntitiesStream() {
    _noRushSubscription = _repo
        .getRemindersStream()
        .listen((List<NoRushReminderEntity> entities) {
      isEmpty = entities.isEmpty;
      state = entities.map((NoRushReminderEntity val) => val.toModel).toList();
    });
  }

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

    gLogger.i('Saved Reminder in Database | ID: $id');
    return reminder;
  }

  Future<bool> deleteReminder(int id) async {
    final NoRushReminderModel? reminder = _repo.getReminder(id);
    if (reminder == null) {
      gLogger.i('Reminder not found | Cannot perform action.');
      return false;
    }
    await NotificationController.cancelScheduledNotification(
      IdHandler().getGroupKey(
        reminder,
      ),
    );

    final bool removed = _repo.removeReminder(id);
    gLogger.i('Deleted reminder from database | ID: $id | Status: $removed');
    return removed;
  }

  Future<void> postponeReminder(NoRushReminderModel reminder) async {
    final UserSettingsNotifier settings = ref.read(userSettingsProvider);
    final TimeOfDay startTime = settings.noRushStartTime;
    final TimeOfDay endTime = settings.noRushEndTime;
    await saveReminder(
      reminder.copyWith(
        dateTime:
            NoRushReminderModel.generateRandomFutureTime(startTime, endTime),
      ),
    );
  }

  Future<String> getBackup() async {
    final String backup = _repo.getBackup();
    gLogger.i('Created Database Backup');
    return backup;
  }

  Future<void> restoreBackup(String jsonData) async {
    await _repo.restoreBackup(jsonData);
    gLogger.i('Restored Database Backup');
  }
}
