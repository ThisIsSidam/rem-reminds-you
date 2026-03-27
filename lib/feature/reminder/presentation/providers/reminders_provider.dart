// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failures/failure.dart';
import '../../../../core/services/notification_service/notification_service.dart';
import '../../../../main.dart';
import '../../../../shared/utils/id_handler.dart';
import '../../../../shared/utils/logger/app_logger.dart';
import '../../../recurrence/data/models/recurrence_rule.dart';
import '../../data/entities/reminder_entity.dart';
import '../../data/models/no_rush_reminder.dart';
import '../../data/models/reminder.dart';
import '../../data/models/reminder_base.dart';
import '../../data/repositories/reminders_repo.dart';
import '../screens/reminder_screen.dart';
import 'no_rush_provider.dart';

part 'generated/reminders_provider.g.dart';

@riverpod
class RemindersNotifier extends _$RemindersNotifier {
  final RemindersRepository _repo = getIt<RemindersRepository>();
  StreamSubscription<List<ReminderEntity>>? _remindersSubscrioption;

  @override
  Map<ReminderSection, List<ReminderModel>> build() {
    _handleEntitiesStream();

    // Handle dispose
    ref.onDispose(() => _remindersSubscrioption?.cancel());

    AppLogger.i('RemindersNotifier initialized');
    return <ReminderSection, List<ReminderModel>>{};
  }

  void _handleEntitiesStream() {
    _remindersSubscrioption = _repo.getRemindersStream().listen((
      List<ReminderEntity> entities,
    ) {
      final List<ReminderModel> reminders = entities
          .map((ReminderEntity val) => val.toModel)
          .toList();
      state = _updateCategorizedReminders(reminders);
    });
  }

  /// Returns true if any one of the sections has a reminder
  bool isEmpty() =>
      !state.values.any((List<ReminderModel> element) => element.isNotEmpty);

  Map<ReminderSection, List<ReminderModel>> _updateCategorizedReminders(
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

    return <ReminderSection, List<ReminderModel>>{
      ReminderSection.overdue: overdueList,
      ReminderSection.today: todayList,
      ReminderSection.tomorrow: tomorrowList,
      ReminderSection.later: laterList,
    };
  }

  Future<ReminderModel> saveReminder(ReminderModel reminder) async {
    await NotificationController.cancelScheduledNotification(
      IdHandler.getReminderGroupKey(reminder),
    );

    final int id = _repo.saveReminder(reminder.toEntity);

    if (!reminder.paused) {
      // Only reschedule if reminder is NOT paused
      await NotificationController.scheduleReminder(reminder.copyWith(id: id));
    }
    AppLogger.i('Saved Reminder in Database | ID: $id');
    return reminder;
  }

  Future<void> deleteReminder(int id) async {
    final ReminderModel? reminder = _repo.getReminder(id);
    if (reminder == null) {
      AppLogger.w('Reminder not found | Cannot perform action.');
      return;
    }
    await NotificationController.cancelScheduledNotification(
      IdHandler.getReminderGroupKey(reminder),
    );

    _repo.removeReminder(id);
    AppLogger.i('Deleted Reminder from Database | ID: $id');
  }

  Future<void> markAsDone(List<int> ids) async {
    for (final int id in ids) {
      final ReminderModel? reminder = _repo.getReminder(id);

      AppLogger.i('Marking Reminder as Done');
      if (reminder == null) {
        AppLogger.w('Reminder not found | Cannot perform action.');
        return;
      }
      if (!reminder.isRecurring) {
        AppLogger.i('Deleting reminder | ID: ${reminder.id}');
        await deleteReminder(reminder.id);
      } else {
        AppLogger.i(
          'Moving Reminder to next occurrence | ID: ${reminder.id} | DT: ${reminder.dateTime}',
        );
        await moveToNextReminderOccurrence(id);
      }

      await NotificationController.removeNotifications(
        IdHandler.getReminderGroupKey(reminder),
      );
    }
  }

  Future<void> moveToNextReminderOccurrence(int id) async {
    final ReminderModel? reminder = _repo.getReminder(id);
    if (reminder == null) {
      AppLogger.w('Reminder not found | Cannot perform action.');
      return;
    }
    if (!reminder.isRecurring) {
      return;
    }

    await NotificationController.cancelScheduledNotification(
      IdHandler.getReminderGroupKey(reminder),
    );
    reminder.moveToNextOccurrence();
    await NotificationController.scheduleReminder(reminder);

    _repo.saveReminder(reminder.toEntity);

    AppLogger.i(
      'Moved Reminder to next occurrence | ID: ${reminder.id} | DT : ${reminder.dateTime}',
    );
  }

  Future<void> moveToPreviousReminderOccurrence(
    int id,
    DateTime previous,
  ) async {
    final ReminderModel? reminder = _repo.getReminder(id);
    if (reminder == null) {
      AppLogger.w('Reminder not found | Cannot perform action.');
      return;
    }
    if (!reminder.isRecurring) return;

    await NotificationController.cancelScheduledNotification(
      IdHandler.getReminderGroupKey(reminder),
    );
    reminder
      ..baseDateTime = previous
      ..dateTime = previous;
    await NotificationController.scheduleReminder(reminder);

    _repo.saveReminder(reminder.toEntity);

    AppLogger.i(
      'Moved Reminder to next occurrence | ID: ${reminder.id} | DT : ${reminder.dateTime}',
    );
  }

  Future<void> pauseReminder(int id) async {
    final ReminderModel? reminder = _repo.getReminder(id);
    if (reminder == null) {
      AppLogger.w('Reminder not found | Cannot perform action.');
      return;
    }
    if (!reminder.isRecurring) {
      reminder.paused = true;
      await NotificationController.cancelScheduledNotification(
        IdHandler.getReminderGroupKey(reminder),
      );
      _repo.saveReminder(reminder.toEntity);
    }
  }

  Future<void> resumeReminder(int id) async {
    final ReminderModel? reminder = _repo.getReminder(id);
    if (reminder == null) {
      AppLogger.w('Reminder not found | Cannot perform action.');
      return;
    }
    if (!reminder.isRecurring) {
      reminder.paused = false;

      // Upon resume, we move the dataTime to next occurrence until
      // the dateTime is in future
      while (reminder.dateTime.isBefore(DateTime.now())) {
        reminder.moveToNextOccurrence();
      }

      _repo.saveReminder(reminder.toEntity);
      await NotificationController.scheduleReminder(reminder);
    }
  }

  /// Moves a reminder from a [ReminderSection] to a different one.
  /// This involves changing the reminder's date while preserving the time.
  Future<void> moveReminder(
    ReminderBase original,
    ReminderSection section,
  ) async {
    // Get a ReminderModel from the received original.
    // If it is already one, just use it.
    // If not, convert it to one.
    final ReminderModel newReminder = switch (original) {
      ReminderModel() => original,
      NoRushReminderModel(
        :final String title,
        :final DateTime dateTime,
        :final Duration autoSnoozeInterval,
      ) =>
        ReminderModel(
          id: 0,
          title: title,
          dateTime: dateTime,
          preParsedTitle: title,
          autoSnoozeInterval: autoSnoozeInterval,
          // The normal 'no recurring' default mode.
          recurrenceRule: RecurrenceRule(),
          baseDateTime: dateTime,
        ),
      _ => throw UnknownReminderTypeFailure(original.runtimeType),
    };

    // Get new datetime and update create a new updated instance with it.
    final DateTime newDateTime = _getDateTimeForSection(
      newReminder.dateTime,
      section,
    );
    final ReminderModel updatedReminder = newReminder.copyWith(
      dateTime: newDateTime,
      baseDateTime: newReminder.isRecurring
          ? newDateTime
          : newReminder.baseDateTime,
    );

    switch (original) {
      case ReminderModel():
        {
          // No need to handle deletion in case of
          // ReminderModel to ReminderModel since they're in same box,
          // and keeps same id.
          await saveReminder(updatedReminder);
        }
      case NoRushReminderModel():
        {
          // Get notifier instance beforehand since we can't after making a
          // state change using saveReminder call
          final NoRushRemindersNotifier noRushNotifier = ref.read(
            noRushRemindersProvider.notifier,
          );

          // Save the updated reminder
          await saveReminder(updatedReminder);

          // Remove if the old reminder was originally NoRush.
          // This happens because if it was normal, it gets saved in same
          // database, but if NoRush, we save it different and this would duplicate
          // reminders
          await noRushNotifier.deleteReminder(original.id);
        }
    }
  }

  // ----------------------------
  // ----- BACKUP & RESTORE -------------------
  // ----------------------------

  Future<String> getBackup() async {
    final String backup = _repo.getBackup();
    AppLogger.i('Created Database Backup');
    return backup;
  }

  Future<void> restoreBackup(String jsonData) async {
    await _repo.restoreBackup(jsonData);
    AppLogger.i('Restored Database Backup');
  }

  // ----------------------------
  // ----- HELPERS -------------------
  // ----------------------------

  /// Returns a new datetime instance for the reminder.
  /// Used in [moveReminder] to move reminder across sections.
  /// Changes the date of the datetime and not the time.
  DateTime _getDateTimeForSection(DateTime dateTime, ReminderSection section) {
    final DateTime now = DateTime.now();

    return switch (section) {
      ReminderSection.today => _keepTimeButChangeDate(dateTime, now),
      ReminderSection.tomorrow => _keepTimeButChangeDate(
        dateTime,
        now.add(const Duration(days: 1)),
      ),
      ReminderSection.later => _keepTimeButChangeDate(
        dateTime,
        now.add(const Duration(days: 7)),
      ),
      _ => throw 'Unhandled Section Type : $section',
    };
  }

  DateTime _keepTimeButChangeDate(DateTime original, DateTime newDate) {
    final DateTime updated = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      original.hour,
      original.minute,
      original.second,
    );
    if (updated.isBefore(newDate)) {
      return newDate.add(const Duration(hours: 1));
    } else {
      return updated;
    }
  }
}
