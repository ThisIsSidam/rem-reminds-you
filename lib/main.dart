import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:Rem/app.dart';
import 'package:Rem/background_service/bg_service.dart';
import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/reminder_class/duration.g.dart';
import 'package:Rem/reminder_class/reminder.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Hive Database
  await Hive.initFlutter();
  Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(ReminderAdapter());
  await Hive.openBox(remindersBoxName);
  await Hive.openBox(indiValuesBoxName);
  
  RemindersDatabaseController.clearPendingRemovals();

  // Awesome Notification
  await NotificationController.initializeLocalNotifications();

  initializeService();

  runApp(const MyApp());
}
