import 'package:Rem/consts/consts.dart';
import 'package:Rem/main.dart';
import 'package:Rem/notification/notif_permi_rationale.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/widgets/bottom_nav/bottom_nav_bar.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {

        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          lightColorScheme = ColorScheme.fromSwatch(primarySwatch:  Colors.blue);
          darkColorScheme = ColorScheme.fromSwatch(
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          navigatorKey: navigatorKey,
          home: FutureBuilder(
            future: Hive.openBox(indiValuesBoxName),
            builder: (context, stacktrace) {
              return _checkingPermissions
              ? const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const BaseScreen();
            },
          ),
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
          ),
          themeMode: ThemeMode.system,
        );
      }
    );
  }
}