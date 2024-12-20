import 'package:flutter/material.dart';

extension ThemeModeExtension on ThemeMode {
  static ThemeMode? fromString(String value) {
    for (final mode in ThemeMode.values) {
      if (value == mode.toString()) {
        return mode;
      }
    }
    return null;
  }
}
