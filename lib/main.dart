import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/services/notification_service/notification_service.dart';
import 'feature/home/data/repositories/reminders_repo.dart';
import 'objectbox.g.dart';
import 'shared/utils/logger/global_logger.dart';
import 'shared/utils/logger/logs_manager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Global [GetIt] instance.
final GetIt getIt = GetIt.I;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initLogger(directory: await LogsManager().directoryPath);
  await NotificationController.initializeLocalNotifications();

  await _injectDependencies();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

Future<void> _injectDependencies() async {
  // Create SharedPreference instace for getIt registration
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Create Objectbox store instance for getIt registration
  final Directory dir = await getApplicationDocumentsDirectory();
  final Store store = Store(
    getObjectBoxModel(),
    directory: path.join(
      dir.path,
      'objectbox-activity-store',
    ),
  );

  // Register elements to GetIt
  getIt
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton(RemindersRepository(store))
    ..registerSingleton(NoRushRemindersRepository(store));
}
