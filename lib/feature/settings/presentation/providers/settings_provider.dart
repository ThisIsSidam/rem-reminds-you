import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/enums/swipe_actions.dart';
import '../../../../core/extensions/shared_prefs_ext.dart';
import '../../../../core/providers/global_providers.dart';
import '../../../../shared/utils/logger/global_logger.dart';
import 'default_settings.dart';

final ChangeNotifierProvider<UserSettingsNotifier> userSettingsProvider =
    ChangeNotifierProvider<UserSettingsNotifier>(
  (Ref<Object?> ref) {
    final SharedPreferences prefs = ref.watch(sharedPreferencesProvider);
    return UserSettingsNotifier(prefs: prefs);
  },
);

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

  Future<void> setDefaultLeadDuration(Duration value) async {
    const String key = 'defaultLeadDuration';
    await prefs.setDuration(key, value);
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

  Future<void> setDefaultAutoSnoozeDuration(Duration value) async {
    const String key = 'defaultAutoSnoozeDuration';
    await prefs.setDuration(key, value);
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

  Future<void> setQuickTimeSetOption1(DateTime value) async {
    const String key = 'quickTimeSetOption1';
    await prefs.setDateTime(key, value);
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

  Future<void> setQuickTimeSetOption2(DateTime value) async {
    const String key = 'quickTimeSetOption2';
    await prefs.setDateTime(key, value);
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

  Future<void> setQuickTimeSetOption3(DateTime value) async {
    const String key = 'quickTimeSetOption3';
    await prefs.setDateTime(key, value);
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

  Future<void> setQuickTimeSetOption4(DateTime value) async {
    const String key = 'quickTimeSetOption4';
    await prefs.setDateTime(key, value);
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

  Future<void> setQuickTimeEditOption1(Duration value) async {
    const String key = 'quickTimeEditOption1';
    await prefs.setDuration(key, value);
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

  Future<void> setQuickTimeEditOption2(Duration value) async {
    const String key = 'quickTimeEditOption2';
    await prefs.setDuration(key, value);
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

  Future<void> setQuickTimeEditOption3(Duration value) async {
    const String key = 'quickTimeEditOption3';
    await prefs.setDuration(key, value);
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

  Future<void> setQuickTimeEditOption4(Duration value) async {
    const String key = 'quickTimeEditOption4';
    await prefs.setDuration(key, value);
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

  Future<void> setQuickTimeEditOption5(Duration value) async {
    const String key = 'quickTimeEditOption5';
    await prefs.setDuration(key, value);
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

  Future<void> setQuickTimeEditOption6(Duration value) async {
    const String key = 'quickTimeEditOption6';
    await prefs.setDuration(key, value);
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

  Future<void> setQuickTimeEditOption7(Duration value) async {
    const String key = 'quickTimeEditOption7';
    await prefs.setDuration(key, value);
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

  Future<void> setQuickTimeEditOption8(Duration value) async {
    const String key = 'quickTimeEditOption8';
    await prefs.setDuration(key, value);
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

  Future<void> setAutoSnoozeOption1(Duration value) async {
    const String key = 'autoSnoozeOption1';
    await prefs.setDuration(key, value);
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

  Future<void> setAutoSnoozeOption2(Duration value) async {
    const String key = 'autoSnoozeOption2';
    await prefs.setDuration(key, value);
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

  Future<void> setAutoSnoozeOption3(Duration value) async {
    const String key = 'autoSnoozeOption3';
    await prefs.setDuration(key, value);
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

  Future<void> setAutoSnoozeOption4(Duration value) async {
    const String key = 'autoSnoozeOption4';
    await prefs.setDuration(key, value);
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

  Future<void> setAutoSnoozeOption5(Duration value) async {
    const String key = 'autoSnoozeOption5';
    await prefs.setDuration(key, value);
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

  Future<void> setAutoSnoozeOption6(Duration value) async {
    const String key = 'autoSnoozeOption6';
    await prefs.setDuration(key, value);
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

  Future<void> setHomeTileSwipeActionLeft(SwipeAction value) async {
    const String key = 'homeTileSwipeActionLeft';
    await prefs.setSwipeAction(key, value);
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

  Future<void> setHomeTileSwipeActionRight(SwipeAction value) async {
    const String key = 'homeTileSwipeActionRight';
    await prefs.setSwipeAction(key, value);
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

  Future<void> setDefaultPostponeDuration(Duration value) async {
    const String key = 'defaultPostponeDuration';
    await prefs.setDuration(key, value);
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

  Future<void> setThemeMode(ThemeMode value) async {
    const String key = 'themeMode';
    await prefs.setThemeMode(key, value);
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

  Future<void> setQuietHoursStartTime(TimeOfDay value) async {
    const String key = 'quietHoursStartTime';
    await prefs.setTimeOfDay(key, value);
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

  Future<void> setQuietHoursEndTime(TimeOfDay value) async {
    const String key = 'quietHoursEndTime';
    await prefs.setTimeOfDay(key, value);
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

  Future<void> setTextScale(double value) async {
    const String key = 'textScale';
    await prefs.setDouble(key, value);
    notifyListeners();
  }
}
