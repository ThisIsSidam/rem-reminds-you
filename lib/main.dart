import 'package:Rem/app.dart';
import 'package:Rem/consts/enums/hive_enums.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/reminder_class/duration.g.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/logger/global_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'database/pending_removals_db.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initLogger();

  await initHive();

  // Awesome Notification
  await NotificationController.initializeLocalNotifications();

  gLogger.d('debug log');
  gLogger.i('info log');
  gLogger.f('fatal log');
  gLogger.w('warning log');
  gLogger.e('error log');

  runApp(ProviderScope(child: MyApp()));
}

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(ReminderAdapter());

  // Order of openBox statements is crucial. Do not change.
  await Hive.openBox(HiveBoxNames.individualValues.name);
  await Hive.openBox(HiveBoxNames.reminders.name);
  await Hive.openBox(HiveBoxNames.pendingRemovals.name);
  await Hive.openBox(HiveBoxNames.archives.name);
  await Hive.openBox(HiveBoxNames.settings.name);

  await PendingRemovalsDB.clearPendingRemovals();
  gLogger.i('Initialized Hive');
}
