import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/models/no_rush_reminder/no_rush_reminder.dart';
import '../../../../core/data/models/recurring_interval/recurring_interval.dart';
import '../../../../core/data/models/reminder/reminder.dart';
import '../../../../core/data/models/reminder_base/reminder_base.dart';
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
  Duration _autoSnoozeInterval = Duration.zero;
  RecurringInterval _recurringInterval = RecurringInterval();
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
  Duration get autoSnoozeInterval => _autoSnoozeInterval;
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

  void refreshBaseDateTime() {
    _baseDateTime = _dateTime;
  }

  void updateAutoSnoozeInterval(Duration newInterval) {
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

  void cleanTitle() {
    if (_preParsedTitle != _title) {
      _preParsedTitle = _title;
    }
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
    _recurringInterval = RecurringInterval();
    _noRush = isNoRush;
    _isPaused = false;
    notifyListeners();
  }

  void loadValues(ReminderBase reminder) {
    if (reminder is NoRushReminderModel) {
      loadNoRush(reminder);
    } else if (reminder is ReminderModel) {
      loadReminder(reminder);
    }
  }

  void loadReminder(ReminderModel reminder) {
    _id = reminder.id;
    _title = reminder.title;
    _preParsedTitle = reminder.preParsedTitle;
    _dateTime = reminder.dateTime;
    _baseDateTime =
        reminder.isRecurring ? reminder.baseDateTime : DateTime.now();
    _autoSnoozeInterval = reminder.autoSnoozeInterval;
    _recurringInterval = reminder.recurringInterval;
    _noRush = false;
    _isPaused = reminder.paused;
    notifyListeners();
  }

  void loadNoRush(NoRushReminderModel noRush) {
    _id = noRush.id;
    _title = noRush.title;
    _preParsedTitle = noRush.title;
    _dateTime = noRush.dateTime;
    _baseDateTime = noRush.dateTime;
    _autoSnoozeInterval = Duration.zero;
    _recurringInterval = RecurringInterval();
    _noRush = true;
    _isPaused = false;
    notifyListeners();
  }

  ReminderBase constructReminder() {
    final Duration autoSnooze =
        ref.read(userSettingsProvider).defaultAutoSnoozeDuration;

    // First time constructing, baseDatetime and dateTime would be same
    if (id == null) {
      refreshBaseDateTime();
    }

    if (_noRush) {
      return NoRushReminderModel(
        id: id ?? 0,
        title: title,
        autoSnoozeInterval: autoSnooze,
        dateTime: NoRushReminderModel.generateRandomFutureTime(ref),
      );
    }
    return ReminderModel(
      title: title,
      id: id ?? 0,
      dateTime: dateTime,
      autoSnoozeInterval: autoSnoozeInterval,
      baseDateTime: baseDateTime,
      preParsedTitle: preParsedTitle,
      recurringInterval: recurringInterval,
      paused: isPaused,
    );
  }
}

final ChangeNotifierProvider<SheetReminderNotifier> sheetReminderNotifier =
    ChangeNotifierProvider<SheetReminderNotifier>(
        (Ref<SheetReminderNotifier> ref) {
  return SheetReminderNotifier(ref: ref);
});
