import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/enums/hive_enums.dart';
import 'core/hive/custom_adapters/time_of_day_adapter.dart';
import 'core/hive/pending_removals_db.dart';
import 'core/models/no_rush_reminders/no_rush_reminders.dart';
import 'core/models/recurring_interval/recurring_interval.dart';
import 'core/models/recurring_reminder/recurring_reminder.dart';
import 'core/models/reminder_model/reminder_model.dart';
import 'core/services/notification_service/notification_service.dart';
import 'shared/utils/logger/global_logger.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initLogger();

  await initHive();

  // Awesome Notification
  await NotificationController.initializeLocalNotifications();

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive
    ..registerAdapter(TimeOfDayAdapter())
    ..registerAdapter(ReminderModelAdapter())
    ..registerAdapter(RecurringIntervalAdapter())
    ..registerAdapter(RecurringReminderModelAdapter())
    ..registerAdapter(NoRushRemindersModelAdapter());

  // Order of openBox statements is crucial. Do not change.
  await Hive.openBox(HiveBoxNames.individualValues.name);
  await Hive.openBox(HiveBoxNames.reminders.name);
  await Hive.openBox(HiveBoxNames.pendingRemovals.name);
  await Hive.openBox(HiveBoxNames.archives.name);
  await Hive.openBox(HiveBoxNames.settings.name);

  await PendingRemovalsDB.clearPendingRemovals();
  gLogger.i('Initialized Hive');
}
