import 'package:Rem/consts/enums/swipe_actions.dart';
import 'package:Rem/database/settings_db.dart';
import 'package:Rem/utils/extensions/theme_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modals/recurring_interval/recurring_interval.dart';
import '../utils/logger/global_logger.dart';

class UserSettingsNotifier extends ChangeNotifier {
  UserSettingsNotifier() {
    gLogger.i('UserSettingsNotifier initialized');
  }

  @override
  void dispose() {
    gLogger.i('UserSettingsNotifier disposed');
    super.dispose();
  }

  Duration get defaultLeadDuration {
    final dynamic value = SettingsDB.getUserSetting('defaultLeadDuration');
    if (value == null || value is! Duration) {
      return Duration(minutes: 5);
    }
    return value;
  }

  set defaultLeadDuration(Duration value) {
    SettingsDB.setUserSetting('defaultLeadDuration', value);
    notifyListeners();
  }

  Duration get defaultAutoSnoozeDuration {
    final dynamic value =
        SettingsDB.getUserSetting('defaultAutoSnoozeDuration');
    if (value == null || value is! Duration) {
      return Duration(minutes: 5);
    }
    return value;
  }

  set defaultAutoSnoozeDuration(Duration value) {
    SettingsDB.setUserSetting('defaultAutoSnoozeDuration', value);
    notifyListeners();
  }

  RecurringInterval get recurringIntervalFieldValue {
    final dynamic value =
        SettingsDB.getUserSetting('recurringIntervalFieldValue');
    if (value == null || value is! String) {
      return RecurringInterval.none;
    }
    return RecurringInterval.fromString(value);
  }

  set recurringIntervalFieldValue(RecurringInterval value) {
    SettingsDB.setUserSetting('recurringIntervalFieldValue', value.toString());
    notifyListeners();
  }

  DateTime get quickTimeSetOption1 {
    final dynamic value = SettingsDB.getUserSetting('quickTimeSetOption1');
    if (value == null || value is! DateTime) {
      return DateTime(0, 0, 0, 9, 30, 0, 0, 0);
    }
    return value;
  }

  set quickTimeSetOption1(DateTime value) {
    SettingsDB.setUserSetting('quickTimeSetOption1', value);
    notifyListeners();
  }

  DateTime get quickTimeSetOption2 {
    final dynamic value = SettingsDB.getUserSetting('quickTimeSetOption2');
    if (value == null || value is! DateTime) {
      return DateTime(0, 0, 0, 12, 0, 0, 0);
    }
    return value;
  }

  set quickTimeSetOption2(DateTime value) {
    SettingsDB.setUserSetting('quickTimeSetOption2', value);
    notifyListeners();
  }

  DateTime get quickTimeSetOption3 {
    final dynamic value = SettingsDB.getUserSetting('quickTimeSetOption3');
    if (value == null || value is! DateTime) {
      return DateTime(0, 0, 0, 18, 30, 0, 0, 0);
    }
    return value;
  }

  set quickTimeSetOption3(DateTime value) {
    SettingsDB.setUserSetting('quickTimeSetOption3', value);
    notifyListeners();
  }

  DateTime get quickTimeSetOption4 {
    final dynamic value = SettingsDB.getUserSetting('quickTimeSetOption4');
    if (value == null || value is! DateTime) {
      return DateTime(0, 0, 0, 22, 0, 0, 0);
    }
    return value;
  }

  set quickTimeSetOption4(DateTime value) {
    SettingsDB.setUserSetting('quickTimeSetOption4', value);
    notifyListeners();
  }

  Duration get quickTimeEditOption1 {
    final dynamic value = SettingsDB.getUserSetting('quickTimeEditOption1');
    if (value == null || value is! Duration) {
      return Duration(minutes: 10);
    }
    return value;
  }

  set quickTimeEditOption1(Duration value) {
    SettingsDB.setUserSetting('quickTimeEditOption1', value);
    notifyListeners();
  }

  Duration get quickTimeEditOption2 {
    final dynamic value = SettingsDB.getUserSetting('quickTimeEditOption2');
    if (value == null || value is! Duration) {
      return Duration(hours: 1);
    }
    return value;
  }

  set quickTimeEditOption2(Duration value) {
    SettingsDB.setUserSetting('quickTimeEditOption2', value);
    notifyListeners();
  }

  Duration get quickTimeEditOption3 {
    final dynamic value = SettingsDB.getUserSetting('quickTimeEditOption3');
    if (value == null || value is! Duration) {
      return Duration(hours: 3);
    }
    return value;
  }

  set quickTimeEditOption3(Duration value) {
    SettingsDB.setUserSetting('quickTimeEditOption3', value);
    notifyListeners();
  }

  Duration get quickTimeEditOption4 {
    final dynamic value = SettingsDB.getUserSetting('quickTimeEditOption4');
    if (value == null || value is! Duration) {
      return Duration(days: 1);
    }
    return value;
  }

  set quickTimeEditOption4(Duration value) {
    SettingsDB.setUserSetting('quickTimeEditOption4', value);
    notifyListeners();
  }

  Duration get quickTimeEditOption5 {
    final dynamic value = SettingsDB.getUserSetting('quickTimeEditOption5');
    if (value == null || value is! Duration) {
      return Duration(minutes: -10);
    }
    return value;
  }

  set quickTimeEditOption5(Duration value) {
    SettingsDB.setUserSetting('quickTimeEditOption5', value);
    notifyListeners();
  }

  Duration get quickTimeEditOption6 {
    final dynamic value = SettingsDB.getUserSetting('quickTimeEditOption6');
    if (value == null || value is! Duration) {
      return Duration(hours: -1);
    }
    return value;
  }

  set quickTimeEditOption6(Duration value) {
    SettingsDB.setUserSetting('quickTimeEditOption6', value);
    notifyListeners();
  }

  Duration get quickTimeEditOption7 {
    final dynamic value = SettingsDB.getUserSetting('quickTimeEditOption7');
    if (value == null || value is! Duration) {
      return Duration(hours: -3);
    }
    return value;
  }

  set quickTimeEditOption7(Duration value) {
    SettingsDB.setUserSetting('quickTimeEditOption7', value);
    notifyListeners();
  }

  Duration get quickTimeEditOption8 {
    final dynamic value = SettingsDB.getUserSetting('quickTimeEditOption8');
    if (value == null || value is! Duration) {
      return Duration(days: -1);
    }
    return value;
  }

  set quickTimeEditOption8(Duration value) {
    SettingsDB.setUserSetting('quickTimeEditOption8', value);
    notifyListeners();
  }

  Duration get autoSnoozeOption1 {
    final dynamic value = SettingsDB.getUserSetting('autoSnoozeOption1');
    if (value == null || value is! Duration) {
      return Duration(minutes: 5);
    }
    return value;
  }

  set autoSnoozeOption1(Duration value) {
    SettingsDB.setUserSetting('autoSnoozeOption1', value);
    notifyListeners();
  }

  Duration get autoSnoozeOption2 {
    final dynamic value = SettingsDB.getUserSetting('autoSnoozeOption2');
    if (value == null || value is! Duration) {
      return Duration(minutes: 10);
    }
    return value;
  }

  set autoSnoozeOption2(Duration value) {
    SettingsDB.setUserSetting('autoSnoozeOption2', value);
    notifyListeners();
  }

  Duration get autoSnoozeOption3 {
    final dynamic value = SettingsDB.getUserSetting('autoSnoozeOption3');
    if (value == null || value is! Duration) {
      return Duration(minutes: 15);
    }
    return value;
  }

  set autoSnoozeOption3(Duration value) {
    SettingsDB.setUserSetting('autoSnoozeOption3', value);
    notifyListeners();
  }

  Duration get autoSnoozeOption4 {
    final dynamic value = SettingsDB.getUserSetting('autoSnoozeOption4');
    if (value == null || value is! Duration) {
      return Duration(minutes: 30);
    }
    return value;
  }

  set autoSnoozeOption4(Duration value) {
    SettingsDB.setUserSetting('autoSnoozeOption4', value);
    notifyListeners();
  }

  Duration get autoSnoozeOption5 {
    final dynamic value = SettingsDB.getUserSetting('autoSnoozeOption5');
    if (value == null || value is! Duration) {
      return Duration(hours: 1);
    }
    return value;
  }

  set autoSnoozeOption5(Duration value) {
    SettingsDB.setUserSetting('autoSnoozeOption5', value);
    notifyListeners();
  }

  Duration get autoSnoozeOption6 {
    final dynamic value = SettingsDB.getUserSetting('autoSnoozeOption6');
    if (value == null || value is! Duration) {
      return Duration(hours: 2);
    }
    return value;
  }

  set autoSnoozeOption6(Duration value) {
    SettingsDB.setUserSetting('autoSnoozeOption6', value);
    notifyListeners();
  }

  SwipeAction get homeTileSwipeActionLeft {
    final dynamic value = SettingsDB.getUserSetting('homeTileSwipeActionLeft');
    if (value == null || value is! String) {
      return SwipeAction.postpone;
    }
    return SwipeAction.fromString(value);
  }

  set homeTileSwipeActionLeft(SwipeAction value) {
    SettingsDB.setUserSetting('homeTileSwipeActionLeft', value.toString());
    notifyListeners();
  }

  SwipeAction get homeTileSwipeActionRight {
    final dynamic value = SettingsDB.getUserSetting('homeTileSwipeActionRight');
    if (value == null || value is! String) {
      return SwipeAction.done;
    }
    return SwipeAction.fromString(value);
  }

  set homeTileSwipeActionRight(SwipeAction value) {
    SettingsDB.setUserSetting('homeTileSwipeActionRight', value.toString());
    notifyListeners();
  }

  Duration get defaultPostponeDuration {
    final dynamic value = SettingsDB.getUserSetting('defaultPostponeDuration');
    if (value == null || value is! Duration) {
      return Duration(minutes: 30);
    }
    return value;
  }

  set defaultPostponeDuration(Duration value) {
    SettingsDB.setUserSetting('defaultPostponeDuration', value);
    notifyListeners();
  }

  /// [ThemeMode] is a material enum. Not a self-made one.
  /// Hence the the method uses a custom .fromString to get the enum value
  ThemeMode get themeMode {
    final dynamic value = SettingsDB.getUserSetting('themeMode');
    if (value == null || value is! String) {
      return ThemeMode.system;
    }
    return ThemeModeExtension.fromString(value) ?? ThemeMode.system;
  }

  set themeMode(ThemeMode value) {
    SettingsDB.setUserSetting('themeMode', value.toString());
    notifyListeners();
  }
}

final userSettingsProvider =
    ChangeNotifierProvider((ref) => UserSettingsNotifier());
