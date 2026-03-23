import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/enums/swipe_actions.dart';
import '../../../../core/extensions/shared_prefs_ext.dart';
import '../../../../main.dart';
import '../../../../shared/utils/logger/app_logger.dart';
import 'default_settings.dart';
import 'settings_keys.dart';

final ChangeNotifierProvider<UserSettingsNotifier> userSettingsProvider =
    ChangeNotifierProvider<UserSettingsNotifier>((Ref ref) {
      final SharedPreferences prefs = getIt<SharedPreferences>();
      return UserSettingsNotifier(prefs: prefs);
    });

class UserSettingsNotifier extends ChangeNotifier {
  UserSettingsNotifier({required this.prefs}) {
    AppLogger.i('Created User Settings Notifier');
  }
  final SharedPreferences prefs;

  @override
  void dispose() {
    AppLogger.i('User Settings Notifier Disposed');
    super.dispose();
  }

  void resetSettings() {
    for (final MapEntry<SettingsKey, dynamic> entry
        in defaultSettings.entries) {
      final String key = entry.key.name;
      final dynamic value = entry.value;
      if (value is Duration) {
        prefs.setDuration(key, value);
      } else if (value is DateTime) {
        prefs.setDateTime(key, value);
      } else if (value is SwipeAction) {
        prefs.setSwipeAction(key, value);
      } else if (value is ThemeMode) {
        prefs.setThemeMode(key, value);
      } else if (value is TimeOfDay) {
        prefs.setTimeOfDay(key, value);
      } else if (value is double) {
        prefs.setDouble(key, value);
      } else {
        AppLogger.w(
          // ignore: lines_longer_than_80_chars
          'Found unhandled datatype value when resettings settings: ${value.runtimeType}',
        );
      }
    }
    notifyListeners();
  }

  Duration get defaultLeadDuration {
    const SettingsKey key = SettingsKey.defaultLeadDuration;
    final Duration? value = prefs.getDuration(key.name);
    if (value == null) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  Future<void> setDefaultLeadDuration(Duration value) async {
    const SettingsKey key = SettingsKey.defaultLeadDuration;
    await prefs.setDuration(key.name, value);
    notifyListeners();
  }

  Duration get defaultAutoSnoozeDuration {
    const SettingsKey key = SettingsKey.defaultAutoSnoozeDuration;
    final Duration? value = prefs.getDuration(key.name);
    if (value == null) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  Future<void> setDefaultAutoSnoozeDuration(Duration value) async {
    const SettingsKey key = SettingsKey.defaultAutoSnoozeDuration;
    await prefs.setDuration(key.name, value);
    notifyListeners();
  }

  DateTime get quickTimeSetOption1 {
    const SettingsKey key = SettingsKey.quickTimeSetOption1;
    final DateTime? value = prefs.getDateTime(key.name);
    if (value == null) {
      return defaultSettings[key] as DateTime;
    }
    return value;
  }

  Future<void> setQuickTimeSetOption1(DateTime value) async {
    const SettingsKey key = SettingsKey.quickTimeSetOption1;
    await prefs.setDateTime(key.name, value);
    notifyListeners();
  }

  DateTime get quickTimeSetOption2 {
    const SettingsKey key = SettingsKey.quickTimeSetOption2;
    final DateTime? value = prefs.getDateTime(key.name);
    if (value == null) {
      return defaultSettings[key] as DateTime;
    }
    return value;
  }

  Future<void> setQuickTimeSetOption2(DateTime value) async {
    const SettingsKey key = SettingsKey.quickTimeSetOption2;
    await prefs.setDateTime(key.name, value);
    notifyListeners();
  }

  DateTime get quickTimeSetOption3 {
    const SettingsKey key = SettingsKey.quickTimeSetOption3;
    final DateTime? value = prefs.getDateTime(key.name);
    if (value == null) {
      return defaultSettings[key] as DateTime;
    }
    return value;
  }

  Future<void> setQuickTimeSetOption3(DateTime value) async {
    const SettingsKey key = SettingsKey.quickTimeSetOption3;
    await prefs.setDateTime(key.name, value);
    notifyListeners();
  }

  DateTime get quickTimeSetOption4 {
    const SettingsKey key = SettingsKey.quickTimeSetOption4;
    final DateTime? value = prefs.getDateTime(key.name);
    if (value == null) {
      return defaultSettings[key] as DateTime;
    }
    return value;
  }

  Future<void> setQuickTimeSetOption4(DateTime value) async {
    const SettingsKey key = SettingsKey.quickTimeSetOption4;
    await prefs.setDateTime(key.name, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption1 {
    const SettingsKey key = SettingsKey.quickTimeEditOption1;
    final Duration? value = prefs.getDuration(key.name);
    if (value == null) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  Future<void> setQuickTimeEditOption1(Duration value) async {
    const SettingsKey key = SettingsKey.quickTimeEditOption1;
    await prefs.setDuration(key.name, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption2 {
    const SettingsKey key = SettingsKey.quickTimeEditOption2;
    final Duration? value = prefs.getDuration(key.name);
    if (value == null) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  Future<void> setQuickTimeEditOption2(Duration value) async {
    const SettingsKey key = SettingsKey.quickTimeEditOption2;
    await prefs.setDuration(key.name, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption3 {
    const SettingsKey key = SettingsKey.quickTimeEditOption3;
    final Duration? value = prefs.getDuration(key.name);
    if (value == null) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  Future<void> setQuickTimeEditOption3(Duration value) async {
    const SettingsKey key = SettingsKey.quickTimeEditOption3;
    await prefs.setDuration(key.name, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption4 {
    const SettingsKey key = SettingsKey.quickTimeEditOption4;
    final Duration? value = prefs.getDuration(key.name);
    if (value == null) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  Future<void> setQuickTimeEditOption4(Duration value) async {
    const SettingsKey key = SettingsKey.quickTimeEditOption4;
    await prefs.setDuration(key.name, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption5 {
    const SettingsKey key = SettingsKey.quickTimeEditOption5;
    final Duration? value = prefs.getDuration(key.name);
    if (value == null) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  Future<void> setQuickTimeEditOption5(Duration value) async {
    const SettingsKey key = SettingsKey.quickTimeEditOption5;
    await prefs.setDuration(key.name, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption6 {
    const SettingsKey key = SettingsKey.quickTimeEditOption6;
    final Duration? value = prefs.getDuration(key.name);
    if (value == null) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  Future<void> setQuickTimeEditOption6(Duration value) async {
    const SettingsKey key = SettingsKey.quickTimeEditOption6;
    await prefs.setDuration(key.name, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption7 {
    const SettingsKey key = SettingsKey.quickTimeEditOption7;
    final Duration? value = prefs.getDuration(key.name);
    if (value == null) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  Future<void> setQuickTimeEditOption7(Duration value) async {
    const SettingsKey key = SettingsKey.quickTimeEditOption7;
    await prefs.setDuration(key.name, value);
    notifyListeners();
  }

  Duration get quickTimeEditOption8 {
    const SettingsKey key = SettingsKey.quickTimeEditOption8;
    final Duration? value = prefs.getDuration(key.name);
    if (value == null) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  Future<void> setQuickTimeEditOption8(Duration value) async {
    const SettingsKey key = SettingsKey.quickTimeEditOption8;
    await prefs.setDuration(key.name, value);
    notifyListeners();
  }

  Duration get autoSnoozeOption1 {
    const SettingsKey key = SettingsKey.autoSnoozeOption1;
    final Duration? value = prefs.getDuration(key.name);
    if (value == null) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  Future<void> setAutoSnoozeOption1(Duration value) async {
    const SettingsKey key = SettingsKey.autoSnoozeOption1;
    await prefs.setDuration(key.name, value);
    notifyListeners();
  }

  Duration get autoSnoozeOption2 {
    const SettingsKey key = SettingsKey.autoSnoozeOption2;
    final Duration? value = prefs.getDuration(key.name);
    if (value == null) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  Future<void> setAutoSnoozeOption2(Duration value) async {
    const SettingsKey key = SettingsKey.autoSnoozeOption2;
    await prefs.setDuration(key.name, value);
    notifyListeners();
  }

  Duration get autoSnoozeOption3 {
    const SettingsKey key = SettingsKey.autoSnoozeOption3;
    final Duration? value = prefs.getDuration(key.name);
    if (value == null) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  Future<void> setAutoSnoozeOption3(Duration value) async {
    const SettingsKey key = SettingsKey.autoSnoozeOption3;
    await prefs.setDuration(key.name, value);
    notifyListeners();
  }

  Duration get autoSnoozeOption4 {
    const SettingsKey key = SettingsKey.autoSnoozeOption4;
    final Duration? value = prefs.getDuration(key.name);
    if (value == null) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  Future<void> setAutoSnoozeOption4(Duration value) async {
    const SettingsKey key = SettingsKey.autoSnoozeOption4;
    await prefs.setDuration(key.name, value);
    notifyListeners();
  }

  Duration get autoSnoozeOption5 {
    const SettingsKey key = SettingsKey.autoSnoozeOption5;
    final Duration? value = prefs.getDuration(key.name);
    if (value == null) {
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
    const SettingsKey key = SettingsKey.autoSnoozeOption6;
    final Duration? value = prefs.getDuration(key.name);
    if (value == null) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  Future<void> setAutoSnoozeOption6(Duration value) async {
    const SettingsKey key = SettingsKey.autoSnoozeOption6;
    await prefs.setDuration(key.name, value);
    notifyListeners();
  }

  SwipeAction get homeTileSwipeActionLeft {
    const SettingsKey key = SettingsKey.homeTileSwipeActionLeft;
    final SwipeAction? value = prefs.getSwipeAction(key.name);
    if (value == null) {
      return SwipeAction.fromString(defaultSettings[key] as String);
    }
    return value;
  }

  Future<void> setHomeTileSwipeActionLeft(SwipeAction value) async {
    const SettingsKey key = SettingsKey.homeTileSwipeActionLeft;
    await prefs.setSwipeAction(key.name, value);
    notifyListeners();
  }

  SwipeAction get homeTileSwipeActionRight {
    const SettingsKey key = SettingsKey.homeTileSwipeActionRight;
    final SwipeAction? value = prefs.getSwipeAction(key.name);
    if (value == null) {
      return SwipeAction.fromString(defaultSettings[key] as String);
    }
    return value;
  }

  Future<void> setHomeTileSwipeActionRight(SwipeAction value) async {
    const SettingsKey key = SettingsKey.homeTileSwipeActionRight;
    await prefs.setSwipeAction(key.name, value);
    notifyListeners();
  }

  Duration get defaultPostponeDuration {
    const SettingsKey key = SettingsKey.defaultPostponeDuration;
    final Duration? value = prefs.getDuration(key.name);
    if (value == null) {
      return defaultSettings[key] as Duration;
    }
    return value;
  }

  Future<void> setDefaultPostponeDuration(Duration value) async {
    const SettingsKey key = SettingsKey.defaultPostponeDuration;
    await prefs.setDuration(key.name, value);
    notifyListeners();
  }

  ThemeMode get themeMode {
    const SettingsKey key = SettingsKey.themeMode;
    final ThemeMode? value = prefs.getThemeMode(key.name);
    if (value == null) {
      return ThemeMode.system;
    }
    return value;
  }

  Future<void> setThemeMode(ThemeMode value) async {
    const SettingsKey key = SettingsKey.themeMode;
    await prefs.setThemeMode(key.name, value);
    notifyListeners();
  }

  TimeOfDay get noRushStartTime {
    const SettingsKey key = SettingsKey.noRushHoursStartTime;
    final TimeOfDay? value = prefs.getTimeOfDay(key.name);
    if (value == null) {
      return defaultSettings[key] as TimeOfDay;
    }
    return value;
  }

  Future<void> setNoRushStartTime(TimeOfDay value) async {
    const SettingsKey key = SettingsKey.noRushHoursStartTime;
    await prefs.setTimeOfDay(key.name, value);
    notifyListeners();
  }

  TimeOfDay get noRushEndTime {
    const SettingsKey key = SettingsKey.noRushHoursEndTime;
    final TimeOfDay? value = prefs.getTimeOfDay(key.name);
    if (value == null) {
      return defaultSettings[key] as TimeOfDay;
    }
    return value;
  }

  Future<void> setNoRushEndTime(TimeOfDay value) async {
    const SettingsKey key = SettingsKey.noRushHoursEndTime;
    await prefs.setTimeOfDay(key.name, value);
    notifyListeners();
  }

  double get textScale {
    const SettingsKey key = SettingsKey.textScale;
    final double? value = prefs.getDouble(key.name);
    if (value == null) {
      return defaultSettings[key] as double;
    }
    return value;
  }

  Future<void> setTextScale(double value) async {
    const SettingsKey key = SettingsKey.textScale;
    await prefs.setDouble(key.name, value);
    notifyListeners();
  }
}
