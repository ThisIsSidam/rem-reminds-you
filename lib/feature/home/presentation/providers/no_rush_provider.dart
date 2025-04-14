// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/const_strings.dart';
import '../../../../core/data/entities/no_rush_entitiy/no_rush_entity.dart';
import '../../../../core/data/models/no_rush_reminder/no_rush_reminder.dart';
import '../../../../core/services/notification_service/notification_service.dart';
import '../../../../shared/utils/id_handler.dart';
import '../../../../shared/utils/logger/global_logger.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/repositories/reminders_repo.dart';

part 'generated/no_rush_provider.g.dart';

@riverpod
class NoRushRemindersNotifier extends _$NoRushRemindersNotifier {
  @override
  List<NoRushReminderModel> build() {
    gLogger.i('RemindersNotifier initialized');
    final List<NoRushReminderEntity> entities =
        ref.watch(noRushRemindersRepositoryProvider);
    return entities.map((NoRushReminderEntity val) => val.toModel).toList();
  }

  Future<NoRushReminderModel> saveReminder(NoRushReminderModel reminder) async {
    if (reminder.id != newReminderID) {
      await NotificationController.cancelScheduledNotification(
        IdHandler().getGroupKey(reminder),
      );
    }
    final int id = ref
        .read(noRushRemindersRepositoryProvider.notifier)
        .saveReminder(reminder.toEntity);

    await NotificationController.scheduleNotification(
      reminder.copyWith(id: id),
    );

    gLogger.i('Saved Reminder in Database | ID: $id');
    return reminder;
  }

  Future<bool> deleteReminder(
    int id,
  ) async {
    final NoRushReminderModel? reminder =
        ref.read(noRushRemindersRepositoryProvider.notifier).getReminder(id);
    if (reminder == null) {
      gLogger.i('Reminder not found | Cannot perform action.');
      return false;
    }
    await NotificationController.cancelScheduledNotification(
      IdHandler().getGroupKey(
        reminder,
      ),
    );

    final bool removed =
        ref.read(noRushRemindersRepositoryProvider.notifier).removeReminder(id);
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
    final String backup =
        ref.read(noRushRemindersRepositoryProvider.notifier).getBackup();
    gLogger.i('Created Database Backup');
    return backup;
  }

  Future<void> restoreBackup(String jsonData) async {
    await ref
        .read(noRushRemindersRepositoryProvider.notifier)
        .restoreBackup(jsonData);
    gLogger.i('Restored Database Backup');
  }
}
