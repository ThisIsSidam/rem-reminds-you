
import 'package:flutter/material.dart';
import 'package:Rem/consts/const_colors.dart';

final ThemeData myTheme = ThemeData(
  scaffoldBackgroundColor: Color.fromARGB(255,33,34,38),
  primaryColor: ConstColors.blue,
  cardColor: ConstColors.darkGrey,

  iconTheme: const IconThemeData(
    color: ConstColors.white
  ),

  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: ConstColors.white
    )
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: ConstColors.blue,
    foregroundColor: ConstColors.white
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(0),
      backgroundColor: ConstColors.darkGrey,
      foregroundColor: ConstColors.white,
      surfaceTintColor: Colors.transparent,
      shape: BeveledRectangleBorder(),
    )
  ),

  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: ConstColors.white
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: ConstColors.white
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: ConstColors.lightGrey
    ),
    bodyLarge: TextStyle(
      fontSize: 14,
      color: ConstColors.white
    ),
    bodyMedium: TextStyle(
      fontSize: 12,
      color: ConstColors.white
    ),
    bodySmall: TextStyle(
      fontSize: 10,
      color: ConstColors.white
    ),
    labelLarge: TextStyle(
      fontSize: 20,
      color: ConstColors.lightGrey
    )
  ),

  switchTheme: SwitchThemeData(
    trackColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return ConstColors.blue.withOpacity(.48);
    }
    return ConstColors.blue.withOpacity(.48);
  })
  ),

  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Colors.transparent,
    contentPadding: const EdgeInsets.only(
      left: 15,
      top: 10,
      bottom: 10,
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: ConstColors.lightGrey),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: ConstColors.blue),
    ),
  ),

  appBarTheme: const AppBarTheme(
    surfaceTintColor: Colors.transparent,
    shadowColor: ConstColors.darkGrey,
    color: ConstColors.darkGrey,
    elevation: 0
  ),

  colorScheme: ColorScheme.fromSeed(
    seedColor: ConstColors.white,
    primaryContainer: ConstColors.darkGrey,
  ),


);
