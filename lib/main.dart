import 'package:flutter/material.dart';
import 'package:nagger/pages/home_page.dart';
import 'package:nagger/pages/reminder_page.dart';

void main() async {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      routes: {
        '/reminder_page': (context) => const ReminderPage()
      },
    );
  }
}