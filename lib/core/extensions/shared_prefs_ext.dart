import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enums/swipe_actions.dart';

extension SharedPrefsX on SharedPreferences {
  Duration? getDuration(String key) {
    final int? seconds = getInt(key);
    if (seconds == null) return null;
    return Duration(seconds: seconds);
  }

  Future<bool> setDuration(String key, Duration value) async {
    final int seconds = value.inSeconds;
    return setInt(key, seconds);
  }

  DateTime? getDateTime(String key) {
    final int? milliseconds = getInt(key);
    if (milliseconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  Future<bool> setDateTime(String key, DateTime value) async {
    final int milliseconds = value.millisecondsSinceEpoch;
    return setInt(key, milliseconds);
  }

  ThemeMode? getThemeMode(String key) {
    final String? themeModeStr = getString(key);
    if (themeModeStr == null) return null;
    return ThemeMode.values.firstWhere(
      (ThemeMode e) => e.toString() == themeModeStr,
      orElse: () => ThemeMode.system,
    );
  }

  Future<bool> setThemeMode(String key, ThemeMode value) async {
    final String themeModeStr = value.toString();
    return setString(key, themeModeStr);
  }

  SwipeAction? getSwipeAction(String key) {
    final String? swipeActionStr = getString(key);
    if (swipeActionStr == null) return null;
    return SwipeAction.values.firstWhere(
      (SwipeAction e) => e.toString() == swipeActionStr,
      orElse: () => SwipeAction.none,
    );
  }

  Future<bool> setSwipeAction(String key, SwipeAction value) async {
    final String swipeActionStr = value.toString();
    return setString(key, swipeActionStr);
  }

  TimeOfDay? getTimeOfDay(String key) {
    final String? timeOfDayStr = getString(key);
    if (timeOfDayStr == null) return null;
    final List<String> parts = timeOfDayStr.split(':');
    if (parts.length != 2) return null;
    final int? hour = int.tryParse(parts[0]);
    final int? minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<bool> setTimeOfDay(String key, TimeOfDay value) async {
    final String timeOfDayStr = '${value.hour}:${value.minute}';
    return setString(key, timeOfDayStr);
  }
}
