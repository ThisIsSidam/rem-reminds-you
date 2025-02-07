import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/swipe_actions.dart';
import '../../../../core/models/recurring_interval/recurring_interval.dart';
import '../../../../shared/utils/extensions/theme_mode.dart';
import '../../../../shared/utils/logger/global_logger.dart';
import '../../data/hive/settings_db.dart';
import 'default_settings.dart';

class UserSettingsNotifier extends ChangeNotifier {
  UserSettingsNotifier() {
    gLogger.i('UserSettingsNotifier initialized');
  }

  @override
  void dispose() {
    gLogger.i('UserSettingsNotifier disposed');
    super.dispose();
  }

  void resetSettings() {
    for (final MapEntry<String, dynamic> entry in defaultSettings.entries) {
      SettingsDB.setUserSetting(entry.key, entry.value);
    }
    notifyListeners();
  }

  Duration get defaultLeadDuration {
    const String key = 'defaultLeadDuration';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set defaultLeadDuration(Duration value) {
    const String key = 'defaultLeadDuration';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  Duration get defaultAutoSnoozeDuration {
    const String key = 'defaultAutoSnoozeDuration';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set defaultAutoSnoozeDuration(Duration value) {
    const String key = 'defaultAutoSnoozeDuration';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  RecurringInterval get recurringIntervalFieldValue {
    const String key = 'recurringIntervalFieldValue';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! String) {
      return RecurringInterval.none;
    }
    return RecurringInterval.fromString(value);
  }

  set recurringIntervalFieldValue(RecurringInterval value) {
    const String key = 'recurringIntervalFieldValue';
    SettingsDB.setUserSetting(key, value.toString());
    notifyListeners();
  }

  DateTime get quickTimeSetOption1 {
    const String key = 'quickTimeSetOption1';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! DateTime) {
      return defaultSettings[key] as DateTime;
    }
    return value;
  }

  set quickTimeSetOption1(DateTime value) {
    const String key = 'quickTimeSetOption1';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  DateTime get quickTimeSetOption2 {
    const String key = 'quickTimeSetOption2';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! DateTime) {
      return defaultSettings[key] as DateTime;
    }
    return value;
  }

  set quickTimeSetOption2(DateTime value) {
    const String key = 'quickTimeSetOption2';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  DateTime get quickTimeSetOption3 {
    const String key = 'quickTimeSetOption3';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! DateTime) {
      return defaultSettings[key] as DateTime;
    }
    return value;
  }

  set quickTimeSetOption3(DateTime value) {
    const String key = 'quickTimeSetOption3';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  DateTime get quickTimeSetOption4 {
    const String key = 'quickTimeSetOption4';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! DateTime) {
      return defaultSettings[key] as DateTime;
    }
    return value;
  }

  set quickTimeSetOption4(DateTime value) {
    const String key = 'quickTimeSetOption4';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption1 {
    const String key = 'quickTimeEditOption1';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set quickTimeEditOption1(Duration value) {
    const String key = 'quickTimeEditOption1';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption2 {
    const String key = 'quickTimeEditOption2';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set quickTimeEditOption2(Duration value) {
    const String key = 'quickTimeEditOption2';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption3 {
    const String key = 'quickTimeEditOption3';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set quickTimeEditOption3(Duration value) {
    const String key = 'quickTimeEditOption3';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption4 {
    const String key = 'quickTimeEditOption4';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set quickTimeEditOption4(Duration value) {
    const String key = 'quickTimeEditOption4';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption5 {
    const String key = 'quickTimeEditOption5';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set quickTimeEditOption5(Duration value) {
    const String key = 'quickTimeEditOption5';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption6 {
    const String key = 'quickTimeEditOption6';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set quickTimeEditOption6(Duration value) {
    const String key = 'quickTimeEditOption6';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption7 {
    const String key = 'quickTimeEditOption7';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set quickTimeEditOption7(Duration value) {
    const String key = 'quickTimeEditOption7';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption8 {
    const String key = 'quickTimeEditOption8';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set quickTimeEditOption8(Duration value) {
    const String key = 'quickTimeEditOption8';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  Duration get autoSnoozeOption1 {
    const String key = 'autoSnoozeOption1';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set autoSnoozeOption1(Duration value) {
    const String key = 'autoSnoozeOption1';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  Duration get autoSnoozeOption2 {
    const String key = 'autoSnoozeOption2';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set autoSnoozeOption2(Duration value) {
    const String key = 'autoSnoozeOption2';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  Duration get autoSnoozeOption3 {
    const String key = 'autoSnoozeOption3';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set autoSnoozeOption3(Duration value) {
    const String key = 'autoSnoozeOption3';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  Duration get autoSnoozeOption4 {
    const String key = 'autoSnoozeOption4';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set autoSnoozeOption4(Duration value) {
    const String key = 'autoSnoozeOption4';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  Duration get autoSnoozeOption5 {
    const String key = 'autoSnoozeOption5';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set autoSnoozeOption5(Duration value) {
    const String key = 'autoSnoozeOption5';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  Duration get autoSnoozeOption6 {
    const String key = 'autoSnoozeOption6';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set autoSnoozeOption6(Duration value) {
    const String key = 'autoSnoozeOption6';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  SwipeAction get homeTileSwipeActionLeft {
    const String key = 'homeTileSwipeActionLeft';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! String) {
      return SwipeAction.postpone;
    }
    return SwipeAction.fromString(value);
  }

  set homeTileSwipeActionLeft(SwipeAction value) {
    const String key = 'homeTileSwipeActionLeft';
    SettingsDB.setUserSetting(key, value.toString());
    notifyListeners();
  }

  SwipeAction get homeTileSwipeActionRight {
    const String key = 'homeTileSwipeActionRight';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! String) {
      return SwipeAction.done;
    }
    return SwipeAction.fromString(value);
  }

  set homeTileSwipeActionRight(SwipeAction value) {
    const String key = 'homeTileSwipeActionRight';
    SettingsDB.setUserSetting(key, value.toString());
    notifyListeners();
  }

  Duration get defaultPostponeDuration {
    const String key = 'defaultPostponeDuration';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set defaultPostponeDuration(Duration value) {
    const String key = 'defaultPostponeDuration';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  ThemeMode get themeMode {
    const String key = 'themeMode';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! String) {
      return ThemeMode.system;
    }
    return ThemeModeX.fromString(value) ?? ThemeMode.system;
  }

  set themeMode(ThemeMode value) {
    const String key = 'themeMode';
    SettingsDB.setUserSetting(key, value.toString());
    notifyListeners();
  }

  TimeOfDay get quietHoursStartTime {
    const String key = 'quietHoursStartTime';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! TimeOfDay) {
      return defaultSettings[key] as TimeOfDay;
    }
    return value;
  }

  set quietHoursStartTime(TimeOfDay value) {
    const String key = 'quietHoursStartTime';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  TimeOfDay get quietHoursEndTime {
    const String key = 'quietHoursEndTime';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! TimeOfDay) {
      return defaultSettings[key] as TimeOfDay;
    }
    return value;
  }

  set quietHoursEndTime(TimeOfDay value) {
    const String key = 'quietHoursEndTime';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }

  double get textScale {
    const String key = 'textScale';
    final dynamic value = SettingsDB.getUserSetting(key);
    if (value == null || value is! double) {
      return defaultSettings[key] as double;
    }
    return value;
  }

  set textScale(double value) {
    const String key = 'textScale';
    SettingsDB.setUserSetting(key, value);
    notifyListeners();
  }
}

final ChangeNotifierProvider<UserSettingsNotifier> userSettingsProvider =
    ChangeNotifierProvider<UserSettingsNotifier>(
  (Ref<Object?> ref) => UserSettingsNotifier(),
);
