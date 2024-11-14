import 'package:Rem/consts/consts.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/provider/archives_provider.dart';
import 'package:Rem/reminder_class/field_mixins/reminder_status/status.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/generate_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/reminder_database/database.dart';
import '../utils/logger/global_logger.dart';

class RemindersNotifier extends ChangeNotifier {
  Ref? ref;
  RemindersNotifier({this.ref}) {
    gLogger.i('RemindersNotifier initialized');
    loadReminders();
  }

  Map<int, Reminder> _reminders = {};
  Map<String, List<Reminder>> _categorizedReminders = {};

  Map<int, Reminder> get reminders => _reminders;
  Map<String, List<Reminder>> get categorizedReminders => _categorizedReminders;
  int get reminderCount => _reminders.length;

  Future<void> loadReminders() async {
    _reminders = RemindersDatabaseController.getReminders();
    _updateCategorizedReminders();
    notifyListeners();
    gLogger.i('Retrieved reminders from database');
  }

  void _updateCategorizedReminders() {
    final now = DateTime.now();
    final overdueList = <Reminder>[];
    final todayList = <Reminder>[];
    final tomorrowList = <Reminder>[];
    final laterList = <Reminder>[];

    final sortedReminders = _reminders.values.toList()
      ..sort((a, b) => a.getDiffDuration().compareTo(b.getDiffDuration()));

    for (final reminder in sortedReminders) {
      DateTime dateTime = reminder.dateAndTime;
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
      overdueSectionTitle: overdueList,
      todaySectionTitle: todayList,
      tomorrowSectionTitle: tomorrowList,
      laterSectionTitle: laterList
    };
  }

  Future<Reminder> saveReminder(Reminder reminder) async {
    if (reminder.id == newReminderID) {
      reminder.id = generateId(reminder);
      reminder.baseDateTime = reminder.dateAndTime;
    }

    if (reminder.id != newReminderID &&
        reminder.reminderStatus != ReminderStatus.archived) {
      await NotificationController.cancelScheduledNotification(
          reminder.id.toString());
      _reminders.remove(reminder.id);
    }

    if (reminder.reminderStatus == ReminderStatus.archived) {
      reminder.reminderStatus = ReminderStatus.active;
    }

    _reminders[reminder.id] = reminder;
    await NotificationController.scheduleNotification(reminder);
    gLogger.i('Saved Reminder in Database | ID: ${reminder.id}');
    await RemindersDatabaseController.updateReminders(_reminders);
    _updateCategorizedReminders();
    notifyListeners();
    return reminder;
  }

  Future<Reminder?> deleteReminder(int id) async {
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
    if (reminder.recurringInterval == RecurringInterval.none) {
      gLogger.i('Moving Reminder to Archives | ID: ${reminder.id}');
      await moveToArchive(id);
    } else {
      gLogger.i(
          'Moving Reminder to next occurrence | ID: ${reminder.id} | DT: ${reminder.dateAndTime}');
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
    if (reminder == null) return;

    await NotificationController.cancelScheduledNotification(id.toString());
    reminder.moveToNextOccurence();
    await NotificationController.scheduleNotification(reminder);

    _reminders[id] = reminder;
    RemindersDatabaseController.updateReminders(_reminders);

    gLogger.i(
        'Moved Reminder to next occurrence | ID: ${reminder.id} | DT : ${reminder.dateAndTime}');
    _updateCategorizedReminders();
    notifyListeners();
  }

  Future<void> moveToPreviousReminderOccurrence(int id) async {
    final reminder = _reminders[id];
    if (reminder == null) return;

    await NotificationController.cancelScheduledNotification(id.toString());
    reminder.moveToPreviousOccurence();
    await NotificationController.scheduleNotification(reminder);

    _reminders[id] = reminder;
    RemindersDatabaseController.updateReminders(_reminders);

    gLogger.i(
        'Moved Reminder to next occurrence | ID: ${reminder.id} | DT : ${reminder.dateAndTime}');
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

  Future<Reminder?> retrieveFromArchives(int id) async {
    Reminder? reminder;

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
