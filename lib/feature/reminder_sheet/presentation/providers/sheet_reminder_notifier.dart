import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/no_rush_reminders/no_rush_reminders.dart';
import '../../../../core/models/recurring_interval/recurring_interval.dart';
import '../../../../core/models/recurring_reminder/recurring_reminder.dart';
import '../../../../core/models/reminder_model/reminder_model.dart';
import '../../../../shared/utils/generate_id.dart';
import '../../../../shared/utils/logger/global_logger.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class SheetReminderNotifier extends ChangeNotifier {
  SheetReminderNotifier({required this.ref}) {
    final UserSettingsNotifier settings = ref.read(userSettingsProvider);
    _dateTime = DateTime.now().add(settings.defaultLeadDuration);
    _autoSnoozeInterval = settings.defaultAutoSnoozeDuration;

    gLogger.i('SheetReminderNotifier initialized');
  }
  Ref ref;
  int? _id;
  String _title = '';
  String _preParsedTitle = '';
  DateTime _dateTime = DateTime.now();
  DateTime _baseDateTime = DateTime.now();
  Duration? _autoSnoozeInterval;
  RecurringInterval _recurringInterval = RecurringInterval.none;
  bool _noRush = false;
  bool _isPaused = false;

  @override
  void dispose() {
    gLogger.i('ReminderNotifier disposed');
    super.dispose();
  }

  // Getters
  int? get id => _id;
  String get title => _title;
  String get preParsedTitle => _preParsedTitle;
  DateTime get dateTime => _dateTime;
  DateTime get baseDateTime => _baseDateTime;
  Duration? get autoSnoozeInterval => _autoSnoozeInterval;
  RecurringInterval get recurringInterval => _recurringInterval;
  bool get noRush => _noRush;
  bool get isPaused => _isPaused;

  // Setters
  void updateId(int? newId) {
    _id = newId;
    notifyListeners();
  }

  void updateTitle(String newTitle) {
    _title = newTitle;
    notifyListeners();
  }

  void updatePreParsedTitle(String newPreParsedTitle) {
    _preParsedTitle = newPreParsedTitle;
    notifyListeners();
  }

  void updateDateTime(DateTime newDateTime) {
    _dateTime = newDateTime;
    notifyListeners();
  }

  void updateBaseDateTime(DateTime newBaseDateTime) {
    _baseDateTime = newBaseDateTime;
    notifyListeners();
  }

  void updateAutoSnoozeInterval(Duration? newInterval) {
    _autoSnoozeInterval = newInterval;
    notifyListeners();
  }

  void updateRecurringInterval(RecurringInterval newInterval) {
    _recurringInterval = newInterval;
    notifyListeners();
  }

  void toggleNoRushSwitch() {
    _noRush = !_noRush;
    notifyListeners();
  }

  void togglePausedSwitch() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  void resetValuesWith({Duration? customDuration, bool isNoRush = false}) {
    final UserSettingsNotifier settings = ref.read(userSettingsProvider);
    _id = null;
    _title = '';
    _preParsedTitle = '';
    _dateTime =
        DateTime.now().add(customDuration ?? settings.defaultLeadDuration);
    _baseDateTime = DateTime.now();
    _autoSnoozeInterval =
        _autoSnoozeInterval = settings.defaultAutoSnoozeDuration;
    _recurringInterval = RecurringInterval.none;
    _noRush = isNoRush;
    _isPaused = false;
    notifyListeners();
  }

  void loadValues(ReminderModel reminder) {
    _id = reminder.id;
    _title = reminder.title;
    _preParsedTitle = reminder.preParsedTitle;
    _dateTime = reminder.dateTime;
    _baseDateTime = reminder is RecurringReminderModel
        ? reminder.baseDateTime
        : DateTime.now();
    _autoSnoozeInterval = reminder.autoSnoozeInterval;
    _recurringInterval = reminder is RecurringReminderModel
        ? reminder.recurringInterval
        : RecurringInterval.none;
    if (reminder is NoRushRemindersModel) _noRush = true;
    _isPaused = reminder is RecurringReminderModel && reminder.paused;
    notifyListeners();
  }

  ReminderModel constructReminder() {
    final Duration autoSnooze =
        ref.read(userSettingsProvider).defaultAutoSnoozeDuration;

    if (_noRush) {
      return NoRushRemindersModel(
        id: id ?? generateId(),
        title: title,
        autoSnoozeInterval: autoSnooze,
        dateTime: NoRushRemindersModel.generateRandomFutureTime(),
      );
    } else if (_recurringInterval == RecurringInterval.none) {
      return ReminderModel(
        id: id ?? generateId(),
        dateTime: dateTime,
        title: title,
        preParsedTitle: preParsedTitle,
        autoSnoozeInterval: autoSnoozeInterval,
      );
    } else {
      return RecurringReminderModel(
        title: title,
        id: id ?? generateId(),
        dateTime: dateTime,
        autoSnoozeInterval: autoSnoozeInterval,
        baseDateTime: baseDateTime,
        preParsedTitle: preParsedTitle,
        recurringInterval: recurringInterval,
        paused: isPaused,
      );
    }
  }
}

final ChangeNotifierProvider<SheetReminderNotifier> sheetReminderNotifier =
    ChangeNotifierProvider<SheetReminderNotifier>(
        (Ref<SheetReminderNotifier> ref) {
  return SheetReminderNotifier(ref: ref);
});
