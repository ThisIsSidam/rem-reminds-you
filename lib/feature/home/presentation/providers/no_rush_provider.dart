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
class RemindersNotifier extends _$RemindersNotifier {
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

  Future<NoRushReminderModel?> deleteReminder(
    NoRushReminderModel reminder,
  ) async {
    await NotificationController.cancelScheduledNotification(
      reminder.id.toString(),
    );

    ref
        .read(noRushRemindersRepositoryProvider.notifier)
        .removeReminder(reminder.id);
    gLogger.i('Deleted Reminder from Database | ID: ${reminder.id}');
    return reminder;
  }

  Future<void> markAsDone(List<int> ids) async {
    for (final int id in ids) {
      final NoRushReminderModel? reminder =
          ref.read(noRushRemindersRepositoryProvider.notifier).getReminder(id);
      gLogger.i('Marking Reminder as Done');
      if (reminder == null) return;

      await deleteReminder(reminder);

      await NotificationController.removeNotifications(id.toString());
    }
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
