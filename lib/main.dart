import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/global_providers.dart';
import 'core/services/notification_service/notification_service.dart';
import 'objectbox.g.dart';
import 'shared/utils/logger/global_logger.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initLogger();
  await NotificationController.initializeLocalNotifications();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final Directory dir = await getApplicationDocumentsDirectory();
  final Store store = Store(
    getObjectBoxModel(),
    directory: path.join(
      dir.path,
      'objectbox-activity-store',
    ),
  );

  runApp(
    ProviderScope(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(prefs),
        objectboxStoreProvider.overrideWithValue(store),
      ],
      child: const MyApp(),
    ),
  );
}
