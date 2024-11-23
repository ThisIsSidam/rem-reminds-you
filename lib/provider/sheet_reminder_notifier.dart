import 'package:Rem/provider/settings_provider.dart';
import 'package:Rem/utils/logger/global_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modals/recurring_interval/recurring_interval.dart';
import '../modals/recurring_reminder/recurring_reminder.dart';
import '../modals/reminder_modal/reminder_modal.dart';
import '../utils/generate_id.dart';

class SheetReminderNotifier extends ChangeNotifier {
  Ref ref;
  int? _id;
  String _title = '';
  String _preParsedTitle = '';
  DateTime _dateTime = DateTime.now();
  DateTime _baseDateTime = DateTime.now();
  Duration? _autoSnoozeInterval;
  RecurringInterval _recurringInterval = RecurringInterval.none;

  SheetReminderNotifier({required this.ref}) {
    final settings = ref.read(userSettingsProvider);
    _dateTime = DateTime.now().add(settings.defaultLeadDuration);
    _autoSnoozeInterval = settings.defaultAutoSnoozeDuration;

    gLogger.i('SheetReminderNotifier initialized');
  }

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

  void resetValues() {
    final settings = ref.read(userSettingsProvider);
    _id = null;
    _title = '';
    _preParsedTitle = '';
    _dateTime = DateTime.now().add(settings.defaultLeadDuration);
    _baseDateTime = DateTime.now();
    _autoSnoozeInterval =
        _autoSnoozeInterval = settings.defaultAutoSnoozeDuration;
    ;
    _recurringInterval = RecurringInterval.none;
    notifyListeners();
  }

  void loadValues(ReminderModal reminder) {
    _id = reminder.id;
    _title = reminder.title;
    _preParsedTitle = reminder.PreParsedTitle;
    _dateTime = reminder.dateTime;
    _baseDateTime = reminder is RecurringReminderModal
        ? reminder.baseDateTime
        : DateTime.now();
    _autoSnoozeInterval = reminder.autoSnoozeInterval;
    _recurringInterval = reminder is RecurringReminderModal
        ? reminder.recurringInterval
        : RecurringInterval.none;
    notifyListeners();
  }

  ReminderModal constructReminder() {
    if (_recurringInterval == RecurringInterval.none) {
      return ReminderModal(
        id: id ?? generateId(),
        dateTime: dateTime,
        title: title,
        PreParsedTitle: preParsedTitle,
        autoSnoozeInterval: autoSnoozeInterval,
      );
    } else {
      return RecurringReminderModal(
        title: title,
        id: id ?? generateId(),
        dateTime: dateTime,
        autoSnoozeInterval: autoSnoozeInterval,
        baseDateTime: baseDateTime,
        PreParsedTitle: preParsedTitle,
        recurringInterval: recurringInterval,
      );
    }
  }
}

final sheetReminderNotifier =
    ChangeNotifierProvider<SheetReminderNotifier>((ref) {
  return SheetReminderNotifier(ref: ref);
});
