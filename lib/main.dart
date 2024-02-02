import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nagger/data/app_theme.dart';

import 'package:nagger/pages/home_page.dart';
import 'package:nagger/utils/reminder.dart';

void main() async {

  await Hive.initFlutter();

  Hive.registerAdapter(ReminderAdapter());
  await Hive.openBox('reminders');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData(scaffoldBackgroundColor: AppTheme.backgroundColor),
    );
  }
}