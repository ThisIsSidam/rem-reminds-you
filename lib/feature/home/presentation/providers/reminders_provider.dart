import 'package:Rem/core/constants/const_strings.dart';
import 'package:Rem/core/models/no_rush_reminders/no_rush_reminders.dart';
import 'package:Rem/core/models/recurring_reminder/recurring_reminder.dart';
import 'package:Rem/core/services/notification_service/notification_service.dart';
import 'package:Rem/feature/archives/presentation/providers/archives_provider.dart';
import 'package:Rem/feature/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/recurring_interval/recurring_interval.dart';
import '../../../../core/models/reminder_model/reminder_model.dart';
import '../../../../shared/utils/logger/global_logger.dart';
import '../../data/hive/reminders_db.dart';

class RemindersNotifier extends ChangeNotifier {
  Ref? ref;
  RemindersNotifier({this.ref}) {
    gLogger.i('RemindersNotifier initialized');
    loadReminders();
  }

  Map<int, ReminderModel> _reminders = {};
  Map<HomeScreenSection, List<ReminderModel>> _categorizedReminders = {};

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
    final now = DateTime.now();
    final overdueList = <ReminderModel>[];
    final todayList = <ReminderModel>[];
    final tomorrowList = <ReminderModel>[];
    final laterList = <ReminderModel>[];
    final noRushList = <NoRushRemindersModel>[];

    final sortedReminders = _reminders.values.toList()
      ..sort((a, b) => a.getDiffDuration().compareTo(b.getDiffDuration()));

    for (final reminder in sortedReminders) {
      DateTime dateTime = reminder.dateTime;
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

    _categorizedReminders = {
      HomeScreenSection.overdue: overdueList,
      HomeScreenSection.today: todayList,
      HomeScreenSection.tomorrow: tomorrowList,
      HomeScreenSection.later: laterList,
      HomeScreenSection.noRush: noRushList,
    };
  }

  Future<ReminderModel> saveReminder(ReminderModel reminder) async {
    // if (reminder.id == newReminderID) {
    //   reminder.id = generateId(reminder);
    //   reminder.baseDateTime = reminder.dateTime;
    // }

    if (reminder.id != newReminderID &&
        (await ref?.read(archivesProvider).isInArchives(reminder.id) ??
            false)) {
      await NotificationController.cancelScheduledNotification(
          reminder.id.toString());
      _reminders.remove(reminder.id);
    }

    _reminders[reminder.id] = reminder;
    await NotificationController.scheduleNotification(reminder);
    gLogger.i('Saved Reminder in Database | ID: ${reminder.id}');
    await RemindersDatabaseController.updateReminders(_reminders);
    _updateCategorizedReminders();
    notifyListeners();
    return reminder;
  }

  Future<ReminderModel?> deleteReminder(int id) async {
    final reminder = _reminders[id];
    if (reminder == null) return null;

    await NotificationController.cancelScheduledNotification(id.toString());
    await NotificationController.removeNotifications(id.toString());

    _reminders.remove(id);
    gLogger.i('Deleted Reminder from Database | ID: ${reminder.id}');
    RemindersDatabaseController.updateReminders(_reminders);

    _updateCategorizedReminders();
    notifyListeners();
    return reminder;
  }

  Future<void> markAsDone(int id) async {
    final reminder = _reminders[id];
    if (reminder == null) return;

    gLogger.i('Marking Reminder as Done | ID: ${reminder.id}');
    if (reminder is! RecurringReminderModel ||
        reminder.recurringInterval == RecurringInterval.none) {
      gLogger.i('Moving Reminder to Archives | ID: ${reminder.id}');
      await moveToArchive(id);
    } else {
      gLogger.i(
          'Moving Reminder to next occurrence | ID: ${reminder.id} | DT: ${reminder.dateTime}');
      await moveToNextReminderOccurrence(id);
    }

    await NotificationController.removeNotifications(id.toString());
    _updateCategorizedReminders();
    notifyListeners();
  }

  Future<void> moveToArchive(int id) async {
    final reminder = _reminders[id];
    if (reminder == null) return;

    await NotificationController.cancelScheduledNotification(id.toString());
    if (ref == null) {
      ArchivesNotifier().addReminderToArchives(reminder);
    } else {
      ref?.read(archivesProvider).addReminderToArchives(reminder);
    }

    _reminders.remove(id);
    RemindersDatabaseController.updateReminders(_reminders);

    gLogger.i('Moved Reminder to Archives | ID: ${reminder.id}');
    _updateCategorizedReminders();
    notifyListeners();
  }

  Future<void> moveToNextReminderOccurrence(int id) async {
    final reminder = _reminders[id];
    if (reminder == null || reminder is! RecurringReminderModel) {
      return;
    }

    await NotificationController.cancelScheduledNotification(id.toString());
    reminder.moveToNextOccurrence();
    await NotificationController.scheduleNotification(reminder);

    _reminders[id] = reminder;
    RemindersDatabaseController.updateReminders(_reminders);

    gLogger.i(
        'Moved Reminder to next occurrence | ID: ${reminder.id} | DT : ${reminder.dateTime}');
    _updateCategorizedReminders();
    notifyListeners();
  }

  Future<void> moveToPreviousReminderOccurrence(int id) async {
    final reminder = _reminders[id];
    if (reminder == null || reminder is! RecurringReminderModel) return;

    await NotificationController.cancelScheduledNotification(id.toString());
    reminder.moveToPreviousOccurrence();
    await NotificationController.scheduleNotification(reminder);

    _reminders[id] = reminder;
    RemindersDatabaseController.updateReminders(_reminders);

    gLogger.i(
        'Moved Reminder to next occurrence | ID: ${reminder.id} | DT : ${reminder.dateTime}');
    _updateCategorizedReminders();
    notifyListeners();
  }

  Future<void> clearAllReminders() async {
    _reminders.clear();
    RemindersDatabaseController.removeAllReminders();

    gLogger.i('Cleared all Reminders | Len : ${_reminders.length}');
    _updateCategorizedReminders();
    notifyListeners();
  }

  Future<ReminderModel?> retrieveFromArchives(int id) async {
    ReminderModel? reminder;

    gLogger.i('Retrieving reminder from Archives | ID : ${id}');
    if (ref == null) {
      reminder = await ArchivesNotifier().deleteArchivedReminder(id);
    } else {
      reminder = await ref?.read(archivesProvider).deleteArchivedReminder(id);
    }
    if (reminder != null) {
      reminder = await saveReminder(reminder);
      gLogger.i('Retrieved reminder from Archives | ID : ${id}');
      return reminder;
    }
    gLogger.w('Retrieval failed | ID : ${id}');
    return null;
  }

  Future<String> getBackup() async {
    final String backup = await RemindersDatabaseController.getBackup();
    gLogger.i('Created Database Backup');
    return backup;
  }

  Future<void> restoreBackup(String jsonData) async {
    RemindersDatabaseController.restoreBackup(jsonData);
    await loadReminders();
    gLogger.i('Restored Database Backup');
  }

  @override
  void dispose() {
    gLogger.i('RemindersNotifier disposed');
    super.dispose();
  }
}

final remindersProvider = ChangeNotifierProvider<RemindersNotifier>((ref) {
  return RemindersNotifier(ref: ref);
});
