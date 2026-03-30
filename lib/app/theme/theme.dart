import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../enums/app_font.dart';

ThemeData getLightTheme(
  ColorScheme colorScheme, {
  bool useSystemFont = false,
}) => ThemeData(
  fontFamily: useSystemFont ? null : AppFont.josefinSans.name,
  useMaterial3: true,
  colorScheme: colorScheme,
  bottomSheetTheme: const BottomSheetThemeData(
    modalBarrierColor: Colors.black38,
  ),
  textTheme: const TextTheme(bodySmall: TextStyle(color: Colors.grey)),
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light, // for iOS
    ),
  ),
);

ThemeData getDarkTheme(ColorScheme colorScheme, {bool useSystemFont = false}) =>
    ThemeData(
      fontFamily: useSystemFont ? null : AppFont.josefinSans.name,
      useMaterial3: true,
      colorScheme: colorScheme,
      bottomSheetTheme: const BottomSheetThemeData(
        modalBarrierColor: Colors.white38,
      ),
      textTheme: const TextTheme(bodySmall: TextStyle(color: Colors.grey)),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark, // for iOS
        ),
      ),
    );
