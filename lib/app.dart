import 'package:Rem/main.dart';
import 'package:Rem/notification/notif_permi_rationale.dart';
import 'package:flutter/material.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/pages/home_page.dart';
import 'package:Rem/theme/app_theme.dart';
import 'package:flutter/services.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _checkingPermissions = true; // Shows a loading screen until false

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }


  /// Checks for permission. And shows the notificationsRationale if permission not allowed.
  Future<void> _checkPermissions() async { 
    setState(() { _checkingPermissions = true;});

    bool isAllowed = await NotificationController.checkNotificationPermissions();
    if (!isAllowed) {
      if (mounted) {
        isAllowed = await displayNotificationRationale(navigatorKey.currentContext!);
      }
    }

    if (mounted) {
      setState(() { _checkingPermissions = false; });
    }

    if (!isAllowed) { SystemNavigator.pop(); }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: _checkingPermissions
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : const HomePage(),
      theme: myTheme,
    );
  }
}