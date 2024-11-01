import 'package:flutter/material.dart';

final ThemeData myTheme = ThemeData(useMaterial3: true).copyWith(
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
        shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        surfaceTintColor: WidgetStatePropertyAll(Colors.transparent)),
  ),
  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Colors.transparent,
    contentPadding: const EdgeInsets.only(
      left: 15,
      top: 10,
      bottom: 10,
    ),
  ),
  appBarTheme:
      const AppBarTheme(surfaceTintColor: Colors.transparent, elevation: 0),
);
