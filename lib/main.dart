import 'package:Rem/app.dart';
import 'package:Rem/consts/enums/hive_enums.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/utils/logger/global_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'database/pending_removals_db.dart';
import 'modals/duration.g.dart';
import 'modals/recurring_interval/recurring_interval.dart';
import 'modals/recurring_reminder/recurring_reminder.dart';
import 'modals/reminder_modal/reminder_modal.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initLogger();

  await initHive();

  // Awesome Notification
  await NotificationController.initializeLocalNotifications();

  runApp(ProviderScope(child: MyApp()));
}

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(ReminderModalAdapter());
  Hive.registerAdapter(RecurringIntervalAdapter());
  Hive.registerAdapter(RecurringReminderModalAdapter());

  // Order of openBox statements is crucial. Do not change.
  await Hive.openBox(HiveBoxNames.individualValues.name);
  await Hive.openBox(HiveBoxNames.reminders.name);
  await Hive.openBox(HiveBoxNames.pendingRemovals.name);
  await Hive.openBox(HiveBoxNames.archives.name);
  await Hive.openBox(HiveBoxNames.settings.name);

  await PendingRemovalsDB.clearPendingRemovals();
  gLogger.i('Initialized Hive');
}
