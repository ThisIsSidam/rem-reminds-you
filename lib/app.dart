import 'package:flutter/material.dart';
import 'package:nagger/notification/notification.dart';
import 'package:nagger/pages/home_page.dart';
import 'package:nagger/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationController.checkNotificationPermissions();

    return MaterialApp(
      navigatorKey: MyApp.navigatorKey,
      home: const HomePage(),
      theme: myTheme
    );
  }
}