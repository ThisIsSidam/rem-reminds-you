import 'package:flutter/material.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/pages/home_page.dart';
import 'package:Rem/theme/app_theme.dart';

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NotificationController.checkNotificationPermissions();

    return MaterialApp(
      home: const HomePage(),
      theme: myTheme
    );
  }
}