import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/enums/swipe_actions.dart';
import '../../../../core/extensions/shared_prefs_ext.dart';
import '../../../../core/providers/global_providers.dart';
import '../../../../shared/utils/logger/global_logger.dart';
import 'default_settings.dart';

part 'settings_provider.g.dart';

@riverpod
UserSettingsNotifier userSettings(Ref ref) {
  final SharedPreferences prefs = ref.watch(sharedPreferencesProvider);
  return UserSettingsNotifier(prefs: prefs);
}

class UserSettingsNotifier extends ChangeNotifier {
  UserSettingsNotifier({required this.prefs}) {
    gLogger.i('Created User Settings Notifier');
  }
  final SharedPreferences prefs;

  @override
  void dispose() {
    gLogger.i('User Settings Notifier Disposed');
    super.dispose();
  }

  void resetSettings() {
    for (final MapEntry<String, dynamic> entry in defaultSettings.entries) {
      final dynamic value = entry.value;
      if (value is Duration) {
        prefs.setDuration(entry.key, value);
      } else if (value is DateTime) {
        prefs.setDateTime(entry.key, value);
      } else if (value is SwipeAction) {
        prefs.setSwipeAction(entry.key, value);
      } else if (value is ThemeMode) {
        prefs.setThemeMode(entry.key, value);
      } else if (value is TimeOfDay) {
        prefs.setTimeOfDay(entry.key, value);
      } else if (value is double) {
        prefs.setDouble(entry.key, value);
      } else {
        gLogger.w(
          // ignore: lines_longer_than_80_chars
          'Found unhandled datatype value when resettings settings: ${value.runtimeType}',
        );
      }
    }
    notifyListeners();
  }

  Duration get defaultLeadDuration {
    const String key = 'defaultLeadDuration';
    final dynamic value = prefs.getDuration(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set defaultLeadDuration(Duration value) {
    const String key = 'defaultLeadDuration';
    prefs.setDuration(key, value);
    notifyListeners();
  }

  Duration get defaultAutoSnoozeDuration {
    const String key = 'defaultAutoSnoozeDuration';
    final dynamic value = prefs.getDuration(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set defaultAutoSnoozeDuration(Duration value) {
    const String key = 'defaultAutoSnoozeDuration';
    prefs.setDuration(key, value);
    notifyListeners();
  }

  DateTime get quickTimeSetOption1 {
    const String key = 'quickTimeSetOption1';
    final dynamic value = prefs.getDateTime(key);
    if (value == null || value is! DateTime) {
      return defaultSettings[key] as DateTime;
    }
    return value;
  }

  set quickTimeSetOption1(DateTime value) {
    const String key = 'quickTimeSetOption1';
    prefs.setDateTime(key, value);
    notifyListeners();
  }

  DateTime get quickTimeSetOption2 {
    const String key = 'quickTimeSetOption2';
    final dynamic value = prefs.getDateTime(key);
    if (value == null || value is! DateTime) {
      return defaultSettings[key] as DateTime;
    }
    return value;
  }

  set quickTimeSetOption2(DateTime value) {
    const String key = 'quickTimeSetOption2';
    prefs.setDateTime(key, value);
    notifyListeners();
  }

  DateTime get quickTimeSetOption3 {
    const String key = 'quickTimeSetOption3';
    final dynamic value = prefs.getDateTime(key);
    if (value == null || value is! DateTime) {
      return defaultSettings[key] as DateTime;
    }
    return value;
  }

  set quickTimeSetOption3(DateTime value) {
    const String key = 'quickTimeSetOption3';
    prefs.setDateTime(key, value);
    notifyListeners();
  }

  DateTime get quickTimeSetOption4 {
    const String key = 'quickTimeSetOption4';
    final dynamic value = prefs.getDateTime(key);
    if (value == null || value is! DateTime) {
      return defaultSettings[key] as DateTime;
    }
    return value;
  }

  set quickTimeSetOption4(DateTime value) {
    const String key = 'quickTimeSetOption4';
    prefs.setDateTime(key, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption1 {
    const String key = 'quickTimeEditOption1';
    final dynamic value = prefs.getDuration(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set quickTimeEditOption1(Duration value) {
    const String key = 'quickTimeEditOption1';
    prefs.setDuration(key, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption2 {
    const String key = 'quickTimeEditOption2';
    final dynamic value = prefs.getDuration(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set quickTimeEditOption2(Duration value) {
    const String key = 'quickTimeEditOption2';
    prefs.setDuration(key, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption3 {
    const String key = 'quickTimeEditOption3';
    final dynamic value = prefs.getDuration(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set quickTimeEditOption3(Duration value) {
    const String key = 'quickTimeEditOption3';
    prefs.setDuration(key, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption4 {
    const String key = 'quickTimeEditOption4';
    final dynamic value = prefs.getDuration(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set quickTimeEditOption4(Duration value) {
    const String key = 'quickTimeEditOption4';
    prefs.setDuration(key, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption5 {
    const String key = 'quickTimeEditOption5';
    final dynamic value = prefs.getDuration(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set quickTimeEditOption5(Duration value) {
    const String key = 'quickTimeEditOption5';
    prefs.setDuration(key, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption6 {
    const String key = 'quickTimeEditOption6';
    final dynamic value = prefs.getDuration(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set quickTimeEditOption6(Duration value) {
    const String key = 'quickTimeEditOption6';
    prefs.setDuration(key, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption7 {
    const String key = 'quickTimeEditOption7';
    final dynamic value = prefs.getDuration(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set quickTimeEditOption7(Duration value) {
    const String key = 'quickTimeEditOption7';
    prefs.setDuration(key, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption8 {
    const String key = 'quickTimeEditOption8';
    final dynamic value = prefs.getDuration(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set quickTimeEditOption8(Duration value) {
    const String key = 'quickTimeEditOption8';
    prefs.setDuration(key, value);
    notifyListeners();
  }

  Duration get autoSnoozeOption1 {
    const String key = 'autoSnoozeOption1';
    final dynamic value = prefs.getDuration(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set autoSnoozeOption1(Duration value) {
    const String key = 'autoSnoozeOption1';
    prefs.setDuration(key, value);
    notifyListeners();
  }

  Duration get autoSnoozeOption2 {
    const String key = 'autoSnoozeOption2';
    final dynamic value = prefs.getDuration(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set autoSnoozeOption2(Duration value) {
    const String key = 'autoSnoozeOption2';
    prefs.setDuration(key, value);
    notifyListeners();
  }

  Duration get autoSnoozeOption3 {
    const String key = 'autoSnoozeOption3';
    final dynamic value = prefs.getDuration(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set autoSnoozeOption3(Duration value) {
    const String key = 'autoSnoozeOption3';
    prefs.setDuration(key, value);
    notifyListeners();
  }

  Duration get autoSnoozeOption4 {
    const String key = 'autoSnoozeOption4';
    final dynamic value = prefs.getDuration(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set autoSnoozeOption4(Duration value) {
    const String key = 'autoSnoozeOption4';
    prefs.setDuration(key, value);
    notifyListeners();
  }

  Duration get autoSnoozeOption5 {
    const String key = 'autoSnoozeOption5';
    final dynamic value = prefs.getDuration(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set autoSnoozeOption5(Duration value) {
    const String key = 'autoSnoozeOption5';
    prefs.setDuration(key, value);
    notifyListeners();
  }

  Duration get autoSnoozeOption6 {
    const String key = 'autoSnoozeOption6';
    final dynamic value = prefs.getDuration(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set autoSnoozeOption6(Duration value) {
    const String key = 'autoSnoozeOption6';
    prefs.setDuration(key, value);
    notifyListeners();
  }

  SwipeAction get homeTileSwipeActionLeft {
    const String key = 'homeTileSwipeActionLeft';
    final dynamic value = prefs.getSwipeAction(key);
    if (value == null || value is! String) {
      return SwipeAction.postpone;
    }
    return SwipeAction.fromString(value);
  }

  set homeTileSwipeActionLeft(SwipeAction value) {
    const String key = 'homeTileSwipeActionLeft';
    prefs.setSwipeAction(key, value);
    notifyListeners();
  }

  SwipeAction get homeTileSwipeActionRight {
    const String key = 'homeTileSwipeActionRight';
    final dynamic value = prefs.getSwipeAction(key);
    if (value == null || value is! String) {
      return SwipeAction.done;
    }
    return SwipeAction.fromString(value);
  }

  set homeTileSwipeActionRight(SwipeAction value) {
    const String key = 'homeTileSwipeActionRight';
    prefs.setSwipeAction(key, value);
    notifyListeners();
  }

  Duration get defaultPostponeDuration {
    const String key = 'defaultPostponeDuration';
    final dynamic value = prefs.getDuration(key);
    if (value == null || value is! Duration) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  set defaultPostponeDuration(Duration value) {
    const String key = 'defaultPostponeDuration';
    prefs.setDuration(key, value);
    notifyListeners();
  }

  ThemeMode get themeMode {
    const String key = 'themeMode';
    final dynamic value = prefs.getThemeMode(key);
    if (value == null || value is! ThemeMode) {
      return ThemeMode.system;
    }
    return value;
  }

  set themeMode(ThemeMode value) {
    const String key = 'themeMode';
    prefs.setThemeMode(key, value);
    notifyListeners();
  }

  TimeOfDay get quietHoursStartTime {
    const String key = 'quietHoursStartTime';
    final dynamic value = prefs.getTimeOfDay(key);
    if (value == null || value is! TimeOfDay) {
      return defaultSettings[key] as TimeOfDay;
    }
    return value;
  }

  set quietHoursStartTime(TimeOfDay value) {
    const String key = 'quietHoursStartTime';
    prefs.setTimeOfDay(key, value);
    notifyListeners();
  }

  TimeOfDay get quietHoursEndTime {
    const String key = 'quietHoursEndTime';
    final dynamic value = prefs.getTimeOfDay(key);
    if (value == null || value is! TimeOfDay) {
      return defaultSettings[key] as TimeOfDay;
    }
    return value;
  }

  set quietHoursEndTime(TimeOfDay value) {
    const String key = 'quietHoursEndTime';
    prefs.setTimeOfDay(key, value);
    notifyListeners();
  }

  double get textScale {
    const String key = 'textScale';
    final dynamic value = prefs.getDouble(key);
    if (value == null || value is! double) {
      return defaultSettings[key] as double;
    }
    return value;
  }

  set textScale(double value) {
    const String key = 'textScale';
    prefs.setDouble(key, value);
    notifyListeners();
  }
}
