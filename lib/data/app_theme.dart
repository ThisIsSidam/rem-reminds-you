
import 'package:flutter/material.dart';

final ThemeData myTheme = ThemeData(
  primaryColor: Colors.white,
  cardColor: const Color.fromRGBO(122, 46, 14, 1),

  iconTheme: const IconThemeData(
    color: Color.fromRGBO(255, 219, 207, 1)
  ),
  
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color.fromRGBO(122, 46, 14, 1),
    foregroundColor: Color.fromRGBO(255, 219, 207, 1)
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(0),
      backgroundColor: const Color.fromRGBO(122, 46, 14, 1),
      foregroundColor: const Color.fromRGBO(255, 219, 207, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5)
      ),
    )
  ),

  buttonTheme: ButtonThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromRGBO(122, 46, 14, 1),
    )
  ),

  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Color.fromRGBO(255, 219, 207, 1)
    ),
    titleMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color.fromRGBO(255, 219, 207, 1)
    ),
    titleSmall: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: Color.fromRGBO(255, 219, 207, 1)
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Color.fromRGBO(255, 219, 207, 1)
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Color.fromRGBO(255, 219, 207, 1)
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: Color.fromRGBO(255, 219, 207, 1)
    )
  ),

  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color.fromRGBO(122, 46, 14, 1),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color.fromRGBO(122, 46, 14, 1),
        width: 2
      ),
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
    disabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromRGBO(122, 46, 14, 1),),
      borderRadius: BorderRadius.all(Radius.circular(5))
    ), 
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color.fromRGBO(122, 46, 14, 1),
        width: 2.5
      ),
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
  ),

  appBarTheme: const AppBarTheme(
    color: Colors.transparent,
    elevation: 0
  ),

  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.black,
    background: const Color.fromRGBO(32, 27, 24, 1),
    onBackground: const Color.fromRGBO(237, 223, 220, 1)
  )
);
