import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nagger/data/app_theme.dart';
import 'package:nagger/utils/notification.dart';
import 'package:nagger/pages/home_page.dart';
import 'package:nagger/utils/reminder.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {

  // Hive Database
  await Hive.initFlutter();

  Hive.registerAdapter(ReminderAdapter());
  await Hive.openBox('reminders');

  // Notification Service
  WidgetsFlutterBinding.ensureInitialized();

  final localNotificationService = LocalNotificationService();
  await localNotificationService.setup();

  tz.initializeTimeZones();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: myTheme
    );
  }
}