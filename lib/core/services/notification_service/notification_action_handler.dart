import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../feature/settings/presentation/providers/settings_provider.dart';
import '../../../objectbox.g.dart';
import '../../../shared/utils/logger/global_logger.dart';
import '../../data/entities/no_rush_entitiy/no_rush_entity.dart';
import '../../data/entities/reminder_entitiy/reminder_entity.dart';
import '../../data/models/no_rush_reminder/no_rush_reminder.dart';
import '../../data/models/reminder/reminder.dart';
import '../../data/models/reminder_base/reminder_base.dart';
import 'notification_service.dart';

class NotificationActionHandler {
  const NotificationActionHandler({
    required this.reminder,
    required this.store,
  });

  final ReminderBase reminder;
  final Store store;

  /// Redirects to specific done handler based on the type attribute
  void donePressed() {
    gLogger.i('Notification action | Done Button Pressed');

    if (reminder is ReminderModel) {
      _normalDonePressed();
    } else if (reminder is NoRushReminderModel) {
      _noRushDonePressed();
    } else {
      throw 'Unhandled reminder type';
    }
  }

  /// Redirects to specific postpone handler based on the type attribute
  Future<void> postponePressed() async {
    gLogger.i('Notification action | Done Button Pressed');

    if (reminder is ReminderModel) {
      await _normalPostponePressed();
    } else if (reminder is NoRushReminderModel) {
      await _noRushPostponePressed();
    } else {
      throw 'Unhandled reminder type';
    }
  }

  /// Removed reminder from the box
  void _noRushDonePressed() {
    final Box<NoRushReminderEntity> box = store.box<NoRushReminderEntity>();
    final bool deleted = box.remove(reminder.id);
    gLogger.i('No Rush Reminder deletion status: $deleted');
  }

  /// Retreives remidner from box, gets the model instance,
  /// checks whether the reminder is recurring.
  ///
  /// If yes, moves reminder to next occurrence,
  /// if not, removes the reminder from box.
  Future<void> _normalDonePressed() async {
    final Box<ReminderEntity> box = store.box<ReminderEntity>();
    final ReminderEntity? entity = box.get(reminder.id);
    if (entity == null) {
      gLogger.i('Reminder not found in database | Done action cancelled');
      return;
    }
    final ReminderModel model = entity.toModel;
    if (model.isRecurring) {
      model.moveToNextOccurrence();
      box.put(model.toEntity);

      await NotificationController.scheduleNotification(model);
      gLogger.i('Reminder moved to next occurrence : ${model.dateTime}');
      return;
    }
    final bool deleted = box.remove(reminder.id);
    gLogger.i('Reminder deletion status: $deleted');
  }

  /// Opens box, retrieves the entitiy object and converts it to model.
  /// Gets sharedPref instance, fetches required info to generate random
  /// dateTime instance. Adds that time to the model dataTime, schedules
  /// the reminder and then saves it.
  Future<void> _noRushPostponePressed() async {
    final Box<NoRushReminderEntity> box = store.box<NoRushReminderEntity>();
    final NoRushReminderEntity? entity = box.get(reminder.id);
    if (entity == null) {
      // ignore: lines_longer_than_80_chars
      gLogger.i('NoRushReminder not found in database | Done action cancelled');
      return;
    }
    final NoRushReminderModel model = entity.toModel;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final UserSettingsNotifier settings = UserSettingsNotifier(prefs: prefs);
    final TimeOfDay startTime = settings.noRushStartTime;
    final TimeOfDay endTime = settings.noRushEndTime;
    model.dateTime =
        NoRushReminderModel.generateRandomFutureTime(startTime, endTime);
    final int id = box.put(model.toEntity);
    await NotificationController.scheduleNotification(
      model.copyWith(id: id),
    );
    gLogger.i('NoRushReminder ${model.id} postponed to ${model.dateTime}');
  }

  /// Opens box, retrieves the entitiy object and converts it to model.
  /// Gets sharedPref instance, fetches required info to get postponeDuration
  /// Adds the duration to the model dataTime and schedules the reminder
  /// and saves the reminder
  Future<void> _normalPostponePressed() async {
    final Box<ReminderEntity> box = store.box<ReminderEntity>();
    final ReminderEntity? entity = box.get(reminder.id);
    if (entity == null) {
      gLogger.i('Reminder not found in database | Done action cancelled');
      return;
    }
    final ReminderModel model = entity.toModel;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final UserSettingsNotifier settings = UserSettingsNotifier(prefs: prefs);
    model.dateTime = model.getPostponeDt(settings.defaultPostponeDuration);
    final int id = box.put(model.toEntity);
    await NotificationController.scheduleNotification(
      model.copyWith(id: id),
    );
    gLogger.i('Reminder ${model.id} postponed to ${model.dateTime}');
  }
}
