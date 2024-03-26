
import 'package:flutter/material.dart';

final ThemeData myTheme = ThemeData(
  primaryColor: Colors.white,
  cardColor: Colors.blueAccent,

  iconTheme: const IconThemeData(
    color: Colors.black
  ),
  
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.blueAccent,
    foregroundColor: Colors.black
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(0),
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5)
      ),
    )
  ),

  buttonTheme: ButtonThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueAccent,
    )
  ),


  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black
    ),
    titleMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black
    ),
    titleSmall: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: Colors.black
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Colors.black
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Colors.black
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: Colors.black
    ),
    labelLarge: TextStyle(
      fontSize: 20,
      color: Colors.white
    )
  ),

  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.blueAccent,
        width: 2
      ),
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
    disabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blueAccent,),
      borderRadius: BorderRadius.all(Radius.circular(5))
    ), 
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.blueAccent,
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
    background: Colors.white,
    onBackground: const Color.fromRGBO(237, 223, 220, 1)
  )
);
