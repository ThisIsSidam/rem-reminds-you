import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nagger/app.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/notification/notification.dart';
import 'package:nagger/reminder_class/reminder.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Hive Database
  await Hive.initFlutter();
  Hive.registerAdapter(ReminderAdapter());
  await Hive.openBox(remindersBoxName);

  await NotificationController.initializeLocalNotifications();

  runApp(const MyApp());
}

