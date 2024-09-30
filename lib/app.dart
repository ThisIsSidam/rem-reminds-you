import 'package:Rem/consts/consts.dart';
import 'package:Rem/main.dart';
import 'package:Rem/notification/notif_permi_rationale.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/provider/text_scale_notifier.dart';
import 'package:Rem/theme/app_theme.dart';
import 'package:Rem/widgets/bottom_nav/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
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
    TextScaleNotifier textScaleNotifier = ref.watch(textScaleProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      builder: (context, child) {
        return MediaQuery(
         child: child!,
         data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(
          textScaleNotifier.textScale
         )),
       );
      },
      home: FutureBuilder(
        future: Hive.openBox(indiValuesBoxName),
        builder: (context, stacktrace) {
          return _checkingPermissions
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : const NavigationSection();
        },
      ),
      theme: myTheme,
    );
  }
}