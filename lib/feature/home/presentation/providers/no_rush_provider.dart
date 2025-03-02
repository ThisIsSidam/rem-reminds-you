// ignore_for_file: lines_longer_than_80_chars

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/const_strings.dart';
import '../../../../core/data/entities/no_rush_entitiy/no_rush_entity.dart';
import '../../../../core/data/models/no_rush_reminder/no_rush_reminder.dart';
import '../../../../core/services/notification_service/notification_service.dart';
import '../../../../shared/utils/logger/global_logger.dart';
import '../../data/repositories/reminders_repo.dart';

part 'no_rush_provider.g.dart';

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
        reminder.id.toString(),
      );
      // _reminders.remove(reminder.id);
    }
    await NotificationController.scheduleNotification(reminder);

    ref
        .read(noRushRemindersRepositoryProvider.notifier)
        .saveReminder(reminder.toEntity);
    gLogger.i('Saved Reminder in Database | ID: ${reminder.id}');
    return reminder;
  }

  Future<bool> deleteReminder(
    int id,
  ) async {
    await NotificationController.cancelScheduledNotification(
      id.toString(),
    );

    final bool removed =
        ref.read(noRushRemindersRepositoryProvider.notifier).removeReminder(id);
    gLogger.i('Deleted reminder from database | ID: $id | Status: $removed');
    return removed;
  }

  Future<void> postponeReminder(NoRushReminderModel reminder) async {
    await saveReminder(
      reminder.copyWith(
        dateTime: NoRushReminderModel.generateRandomFutureTime(ref),
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
    ref
        .read(noRushRemindersRepositoryProvider.notifier)
        .restoreBackup(jsonData);
    gLogger.i('Restored Database Backup');
  }
}
