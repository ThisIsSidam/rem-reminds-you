import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:Rem/app.dart';
import 'package:Rem/background_service/bg_service.dart';
import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/reminder_class/duration.g.dart';
import 'package:Rem/reminder_class/reminder.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(ReminderAdapter());

  // Order of openBox statements is crucial. Do not change.
  await Hive.openBox(indiValuesBoxName);
  await Hive.openBox(remindersBoxName);
  await Hive.openBox(archivesBoxName);
}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await initHive();

  RemindersDatabaseController.clearPendingRemovals();

  // Awesome Notification
  await NotificationController.initializeLocalNotifications();

  initializeService();

  runApp(ProviderScope(
    child: MyApp()
  ));
}
