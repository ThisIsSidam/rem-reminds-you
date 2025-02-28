// ignore_for_file: lines_longer_than_80_chars

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/entities/reminder_entitiy/reminder_entity.dart';
import '../../../../core/data/models/reminder/reminder.dart';
import '../../../../core/services/notification_service/notification_service.dart';
import '../../../../shared/utils/logger/global_logger.dart';
import '../../data/repositories/reminders_repo.dart';
import '../screens/home_screen.dart';

part 'reminders_provider.g.dart';

@riverpod
class RemindersNotifier extends _$RemindersNotifier {
  @override
  Map<HomeScreenSection, List<ReminderModel>> build() {
    gLogger.i('RemindersNotifier initialized');
    final List<ReminderEntity> entities =
        ref.watch(remindersRepositoryProvider);
    final List<ReminderModel> reminders =
        entities.map((ReminderEntity val) => val.toModel).toList();
    return _updateCategorizedReminders(reminders);
  }

  Map<HomeScreenSection, List<ReminderModel>> _updateCategorizedReminders(
    List<ReminderModel> reminders,
  ) {
    final DateTime now = DateTime.now();
    final List<ReminderModel> overdueList = <ReminderModel>[];
    final List<ReminderModel> todayList = <ReminderModel>[];
    final List<ReminderModel> tomorrowList = <ReminderModel>[];
    final List<ReminderModel> laterList = <ReminderModel>[];

    final List<ReminderModel> sortedReminders = reminders
      ..sort(
        (ReminderModel a, ReminderModel b) =>
            a.getDiffDuration().compareTo(b.getDiffDuration()),
      );

    for (final ReminderModel reminder in sortedReminders) {
      final DateTime dateTime = reminder.dateTime;
      if (dateTime.isBefore(now)) {
        overdueList.add(reminder);
      } else if (dateTime.day == now.day &&
          dateTime.month == now.month &&
          dateTime.year == now.year) {
        todayList.add(reminder);
      } else if (dateTime.day == now.day + 1 &&
          dateTime.month == now.month &&
          dateTime.year == now.year) {
        tomorrowList.add(reminder);
      } else {
        laterList.add(reminder);
      }
    }

    return <HomeScreenSection, List<ReminderModel>>{
      HomeScreenSection.overdue: overdueList,
      HomeScreenSection.today: todayList,
      HomeScreenSection.tomorrow: tomorrowList,
      HomeScreenSection.later: laterList,
    };
  }

  Future<ReminderModel> saveReminder(ReminderModel reminder) async {
    await NotificationController.cancelScheduledNotification(
      reminder.id.toString(),
    );

    final int id = ref
        .read(remindersRepositoryProvider.notifier)
        .saveReminder(reminder.toEntity);

    if (!reminder.paused) {
      // Only reschedule if reminder is NOT paused
      await NotificationController.scheduleNotification(
        reminder.copyWith(id: id),
      );
    }
    gLogger.i('Saved Reminder in Database | ID: $id');
    return reminder;
  }

  Future<void> deleteReminder(int id) async {
    await NotificationController.cancelScheduledNotification(
      id.toString(),
    );

    ref.read(remindersRepositoryProvider.notifier).removeReminder(id);
    gLogger.i('Deleted Reminder from Database | ID: $id');
  }

  Future<void> markAsDone(List<int> ids) async {
    for (final int id in ids) {
      final ReminderModel? reminder =
          ref.read(remindersRepositoryProvider.notifier).getReminder(id);

      gLogger.i('Marking Reminder as Done');
      if (reminder == null) {
        gLogger.i('Reminder not found | Cannot perform action.');
        return;
      }
      if (!reminder.isRecurring) {
        gLogger.i('Deleting reminder | ID: ${reminder.id}');
        await deleteReminder(reminder.id);
      } else {
        gLogger.i(
          'Moving Reminder to next occurrence | ID: ${reminder.id} | DT: ${reminder.dateTime}',
        );
        await moveToNextReminderOccurrence(id);
      }

      await NotificationController.removeNotifications(id.toString());
    }
  }

  Future<void> moveToNextReminderOccurrence(int id) async {
    final ReminderModel? reminder =
        ref.read(remindersRepositoryProvider.notifier).getReminder(id);
    if (reminder == null) {
      gLogger.i('Reminder not found | Cannot perform action.');
      return;
    }
    if (!reminder.isRecurring) {
      return;
    }

    await NotificationController.cancelScheduledNotification(id.toString());
    reminder.moveToNextOccurrence();
    await NotificationController.scheduleNotification(reminder);

    ref
        .read(remindersRepositoryProvider.notifier)
        .saveReminder(reminder.toEntity);

    gLogger.i(
      'Moved Reminder to next occurrence | ID: ${reminder.id} | DT : ${reminder.dateTime}',
    );
  }

  Future<void> moveToPreviousReminderOccurrence(int id) async {
    final ReminderModel? reminder =
        ref.read(remindersRepositoryProvider.notifier).getReminder(id);
    if (reminder == null) {
      gLogger.i('Reminder not found | Cannot perform action.');
      return;
    }
    if (!reminder.isRecurring) return;

    await NotificationController.cancelScheduledNotification(id.toString());
    reminder.moveToPreviousOccurrence();
    await NotificationController.scheduleNotification(reminder);

    ref
        .read(remindersRepositoryProvider.notifier)
        .saveReminder(reminder.toEntity);

    gLogger.i(
      'Moved Reminder to next occurrence | ID: ${reminder.id} | DT : ${reminder.dateTime}',
    );
  }

  Future<String> getBackup() async {
    final String backup =
        ref.read(remindersRepositoryProvider.notifier).getBackup();
    gLogger.i('Created Database Backup');
    return backup;
  }

  Future<void> restoreBackup(String jsonData) async {
    ref.read(remindersRepositoryProvider.notifier).restoreBackup(jsonData);
    gLogger.i('Restored Database Backup');
  }

  Future<void> pauseReminder(int id) async {
    final ReminderModel? reminder =
        ref.read(remindersRepositoryProvider.notifier).getReminder(id);
    if (reminder == null) {
      gLogger.i('Reminder not found | Cannot perform action.');
      return;
    }
    if (!reminder.isRecurring) {
      reminder.paused = true;
      await NotificationController.cancelScheduledNotification(id.toString());
      ref
          .read(remindersRepositoryProvider.notifier)
          .saveReminder(reminder.toEntity);
    }
  }

  Future<void> resumeReminder(int id) async {
    final ReminderModel? reminder =
        ref.read(remindersRepositoryProvider.notifier).getReminder(id);
    if (reminder == null) {
      gLogger.i('Reminder not found | Cannot perform action.');
      return;
    }
    if (!reminder.isRecurring) {
      reminder.paused = false;

      // Upon resume, we move the dataTime to next occurrence until
      // the dateTime is in future
      while (reminder.dateTime.isBefore(DateTime.now())) {
        reminder.moveToNextOccurrence();
      }

      ref
          .read(remindersRepositoryProvider.notifier)
          .saveReminder(reminder.toEntity);
      await NotificationController.scheduleNotification(reminder);
    }
  }
}
