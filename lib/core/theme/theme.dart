import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData getLightTheme(ColorScheme colorScheme) => ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      bottomSheetTheme: const BottomSheetThemeData(
        modalBarrierColor: Colors.black38,
      ),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light, // for iOS
        ),
      ),
    );

ThemeData getDarkTheme(ColorScheme colorScheme, ThemeMode theme) => ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      bottomSheetTheme: const BottomSheetThemeData(
        modalBarrierColor: Colors.white38,
      ),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark, // for iOS
        ),
      ),
    );
