import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/utils/logger/app_logger.dart';
import '../../../recurrence/data/models/recurrence_rule.dart';
import '../../../reminder/data/models/no_rush_reminder.dart';
import '../../../reminder/data/models/reminder.dart';
import '../../../reminder/data/models/reminder_base.dart';
import '../../../reminder/presentation/providers/no_rush_provider.dart';
import '../../../reminder/presentation/providers/reminders_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/models/sheet_reminder_form.dart';

part 'generated/sheet_reminder_provider.g.dart';

@riverpod
class SheetReminderNotifier extends _$SheetReminderNotifier {
  @override
  SheetReminderForm build() {
    final settings = ref.read(userSettingsProvider);
    final base = SheetReminderForm.initial(
      leadDuration: settings.defaultLeadDuration,
      defaultAutoSnoozeDuration: settings.defaultAutoSnoozeDuration,
    );

    AppLogger.i('SheetReminderNotifier initialized');
    return base;
  }

  // -----------------------
  // Updates
  // -----------------------

  void updateId(int? id) {
    state = state.copyWith(id: id ?? 0);
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updatePreParsedTitle(String value) {
    state = state.copyWith(preParsedTitle: value);
  }

  void updateDateTime(DateTime dt) {
    state = state.copyWith(dateTime: dt);
  }

  void updateBaseDateTime(DateTime dt) {
    state = state.copyWith(baseDateTime: dt);
  }

  void refreshBaseDateTime() {
    state = state.copyWith(baseDateTime: state.dateTime);
  }

  void updateAutoSnoozeInterval(Duration d) {
    state = state.copyWith(autoSnoozeInterval: d);
  }

  void updateRecurrenceRule(RecurrenceRule rule) {
    state = state.copyWith(recurrenceRule: rule);
  }

  void toggleNoRush() {
    state = state.copyWith(noRush: !state.noRush);
  }

  void togglePaused() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  void cleanTitle() {
    if (state.preParsedTitle != state.title) {
      state = state.copyWith(preParsedTitle: state.title);
    }
  }

  // -----------------------
  // Reset / Load
  // -----------------------

  void reset({Duration? customDuration, bool isNoRush = false}) {
    final settings = ref.read(userSettingsProvider);

    state = SheetReminderForm.initial(
      leadDuration: settings.defaultLeadDuration,
      defaultAutoSnoozeDuration: settings.defaultAutoSnoozeDuration,
    );
  }

  // -----------------------
  // Delete
  // -----------------------

  void deleteReminder(int id) {
    if (state.noRush) {
      ref.read(noRushRemindersProvider.notifier).deleteReminder(id);
    } else {
      ref.read(remindersProvider.notifier).deleteReminder(id);
    }
  }

  // -----------------------
  // Construct Models
  // -----------------------

  ReminderBase constructReminder() {
    final toBeType = state.noRush ? ReminderType.noRush : ReminderType.normal;

    if (state.originalType != toBeType && state.id != 0) {
      _handleTypeChange();
    }

    return state.noRush ? constructNoRush() : _constructNormal();
  }

  ReminderModel _constructNormal() {
    if (state.id == 0) {
      refreshBaseDateTime();
    }

    return ReminderModel(
      id: state.id,
      title: state.title,
      preParsedTitle: state.preParsedTitle,
      dateTime: state.dateTime,
      baseDateTime: state.baseDateTime,
      autoSnoozeInterval: state.autoSnoozeInterval,
      recurrenceRule: state.recurrenceRule,
      paused: state.isPaused,
    );
  }

  NoRushReminderModel constructNoRush({bool newDateTime = false}) {
    final settings = ref.read(userSettingsProvider);

    return NoRushReminderModel(
      id: state.id,
      title: state.title,
      autoSnoozeInterval: settings.defaultAutoSnoozeDuration,
      dateTime: state.id == 0 || newDateTime
          ? NoRushReminderModel.generateRandomFutureTime(
              settings.noRushStartTime,
              settings.noRushEndTime,
            )
          : state.dateTime,
    );
  }

  // -----------------------
  // Type Change Handling
  // -----------------------

  void _handleTypeChange() {
    if (state.originalType == ReminderType.normal) {
      ref.read(remindersProvider.notifier).deleteReminder(state.id);
    } else if (state.originalType == ReminderType.noRush) {
      ref.read(noRushRemindersProvider.notifier).deleteReminder(state.id);
    }

    state = state.copyWith(id: 0);
  }
}
