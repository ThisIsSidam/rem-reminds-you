// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/const_strings.dart';
import '../../../../core/data/models/no_rush_reminders/no_rush_reminders.dart';
import '../../../../core/data/models/recurring_interval/recurring_interval.dart';
import '../../../../core/data/models/recurring_reminder/recurring_reminder.dart';
import '../../../../core/data/models/reminder_model/reminder_model.dart';
import '../../../../core/services/notification_service/notification_service.dart';
import '../../../../shared/utils/logger/global_logger.dart';
import '../../../archives/presentation/providers/archives_provider.dart';
import '../../data/hive/reminders_db.dart';
import '../screens/home_screen.dart';

class RemindersNotifier extends ChangeNotifier {
  RemindersNotifier({required this.ref}) {
    gLogger.i('RemindersNotifier initialized');
    loadReminders();
  }
  Ref ref;

  Map<int, ReminderModel> _reminders = <int, ReminderModel>{};
  Map<HomeScreenSection, List<ReminderModel>> _categorizedReminders =
      <HomeScreenSection, List<ReminderModel>>{};

  Map<int, ReminderModel> get reminders => _reminders;

  Map<HomeScreenSection, List<ReminderModel>> get categorizedReminders {
    _updateCategorizedReminders();
    return _categorizedReminders;
  }

  int get reminderCount => _reminders.length;

  Future<void> loadReminders() async {
    _reminders = RemindersDatabaseController.getReminders();
    _updateCategorizedReminders();
    notifyListeners();
    gLogger.i('Retrieved reminders from database');
  }

  void _updateCategorizedReminders() {
    final DateTime now = DateTime.now();
    final List<ReminderModel> overdueList = <ReminderModel>[];
    final List<ReminderModel> todayList = <ReminderModel>[];
    final List<ReminderModel> tomorrowList = <ReminderModel>[];
    final List<ReminderModel> laterList = <ReminderModel>[];
    final List<NoRushRemindersModel> noRushList = <NoRushRemindersModel>[];

    final List<ReminderModel> sortedReminders = _reminders.values.toList()
      ..sort(
        (ReminderModel a, ReminderModel b) =>
            a.getDiffDuration().compareTo(b.getDiffDuration()),
      );

    for (final ReminderModel reminder in sortedReminders) {
      final DateTime dateTime = reminder.dateTime;
      if (reminder is NoRushRemindersModel) {
        noRushList.add(reminder);
        continue;
      }
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

    _categorizedReminders = <HomeScreenSection, List<ReminderModel>>{
      HomeScreenSection.overdue: overdueList,
      HomeScreenSection.today: todayList,
      HomeScreenSection.tomorrow: tomorrowList,
      HomeScreenSection.later: laterList,
      HomeScreenSection.noRush: noRushList,
    };
  }

  Future<ReminderModel> saveReminder(ReminderModel reminder) async {
    final bool isArchived =
        await ref.read(archivesProvider).isInArchives(reminder.id);
    if (reminder.id != newReminderID || !isArchived) {
      await NotificationController.cancelScheduledNotification(
        reminder.id.toString(),
      );
      _reminders.remove(reminder.id);
    }

    if (reminder is! RecurringReminderModel || !reminder.paused) {
      // Only reschedule if reminder is NOT paused
      await NotificationController.scheduleNotification(reminder);
    }
    await RemindersDatabaseController.saveReminder(reminder.id, reminder);
    _reminders = RemindersDatabaseController.getReminders();
    gLogger.i('Saved Reminder in Database | ID: ${reminder.id}');
    _updateCategorizedReminders();
    notifyListeners();
    return reminder;
  }

  Future<ReminderModel?> deleteReminder(int id) async {
    final ReminderModel? reminder = _reminders[id];
    if (reminder == null) return null;

    await NotificationController.cancelScheduledNotification(id.toString());

    await RemindersDatabaseController.removeReminder(id);
    _reminders = RemindersDatabaseController.getReminders();
    gLogger.i('Deleted Reminder from Database | ID: ${reminder.id}');

    _updateCategorizedReminders();
    notifyListeners();
    return reminder;
  }

  Future<void> markAsDone(List<int> ids) async {
    for (final int id in ids) {
      final ReminderModel? reminder = _reminders[id];
      if (reminder == null) return;

      gLogger.i('Marking Reminder as Done | ID: ${reminder.id}');
      if (reminder is! RecurringReminderModel ||
          reminder.recurringInterval == RecurringInterval.none) {
        gLogger.i('Moving Reminder to Archives | ID: ${reminder.id}');
        await moveToArchive(id);
      } else {
        gLogger.i(
          'Moving Reminder to next occurrence | ID: ${reminder.id} | DT: ${reminder.dateTime}',
        );
        await moveToNextReminderOccurrence(id);
      }

      await NotificationController.removeNotifications(id.toString());
    }
    _updateCategorizedReminders();
    notifyListeners();
  }

  Future<void> moveToArchive(int id) async {
    final ReminderModel? reminder = _reminders[id];
    if (reminder == null) return;

    await NotificationController.cancelScheduledNotification(id.toString());
    await ref.read(archivesProvider).addReminderToArchives(reminder);

    await RemindersDatabaseController.removeReminder(id);
    _reminders = RemindersDatabaseController.getReminders();

    gLogger.i('Moved Reminder to Archives | ID: ${reminder.id}');
    _updateCategorizedReminders();
    notifyListeners();
  }

  Future<void> moveToNextReminderOccurrence(int id) async {
    final ReminderModel? reminder = _reminders[id];
    if (reminder == null || reminder is! RecurringReminderModel) {
      return;
    }

    await NotificationController.cancelScheduledNotification(id.toString());
    reminder.moveToNextOccurrence();
    await NotificationController.scheduleNotification(reminder);

    await RemindersDatabaseController.saveReminder(reminder.id, reminder);
    _reminders = RemindersDatabaseController.getReminders();

    gLogger.i(
      'Moved Reminder to next occurrence | ID: ${reminder.id} | DT : ${reminder.dateTime}',
    );
    _updateCategorizedReminders();
    notifyListeners();
  }

  Future<void> moveToPreviousReminderOccurrence(int id) async {
    final ReminderModel? reminder = _reminders[id];
    if (reminder == null || reminder is! RecurringReminderModel) return;

    await NotificationController.cancelScheduledNotification(id.toString());
    reminder.moveToPreviousOccurrence();
    await NotificationController.scheduleNotification(reminder);

    await RemindersDatabaseController.saveReminder(reminder.id, reminder);
    _reminders = RemindersDatabaseController.getReminders();

    gLogger.i(
      'Moved Reminder to next occurrence | ID: ${reminder.id} | DT : ${reminder.dateTime}',
    );
    _updateCategorizedReminders();
    notifyListeners();
  }

  Future<void> clearAllReminders() async {
    _reminders.clear();
    await RemindersDatabaseController.removeAllReminders();

    gLogger.i('Cleared all Reminders | Len : ${_reminders.length}');
    _updateCategorizedReminders();
    notifyListeners();
  }

  Future<ReminderModel?> retrieveFromArchives(int id) async {
    ReminderModel? reminder;

    gLogger.i('Retrieving reminder from Archives | ID : $id');
    reminder = await ref.read(archivesProvider).deleteArchivedReminder(id);
    if (reminder != null) {
      reminder = await saveReminder(reminder);
      gLogger.i('Retrieved reminder from Archives | ID : $id');
      return reminder;
    }
    gLogger.w('Retrieval failed | ID : $id');
    return null;
  }

  Future<String> getBackup() async {
    final String backup = await RemindersDatabaseController.getBackup();
    gLogger.i('Created Database Backup');
    return backup;
  }

  Future<void> restoreBackup(String jsonData) async {
    await RemindersDatabaseController.restoreBackup(jsonData);
    await loadReminders();
    gLogger.i('Restored Database Backup');
  }

  Future<void> pauseReminder(int id) async {
    final ReminderModel? reminder = _reminders[id];
    if (reminder is RecurringReminderModel &&
        reminder.recurringInterval != RecurringInterval.none) {
      reminder.paused = true;
      _reminders[id] = reminder;
      await NotificationController.cancelScheduledNotification(id.toString());
      await RemindersDatabaseController.updateReminders(_reminders);
      notifyListeners();
    }
  }

  Future<void> resumeReminder(int id) async {
    final ReminderModel? reminder = _reminders[id];
    if (reminder is RecurringReminderModel &&
        reminder.recurringInterval != RecurringInterval.none) {
      reminder.paused = false;

      // Upon resume, we move the dataTime to next occurrence until
      // the dateTime is in future
      while (reminder.dateTime.isBefore(DateTime.now())) {
        reminder.moveToNextOccurrence();
      }

      _reminders[id] = reminder;
      await RemindersDatabaseController.updateReminders(_reminders);
      await NotificationController.scheduleNotification(reminder);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    gLogger.i('RemindersNotifier disposed');
    super.dispose();
  }
}

final ChangeNotifierProvider<RemindersNotifier> remindersProvider =
    ChangeNotifierProvider<RemindersNotifier>((Ref<RemindersNotifier> ref) {
  return RemindersNotifier(ref: ref);
});
