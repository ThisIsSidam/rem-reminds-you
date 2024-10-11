import 'package:Rem/consts/consts.dart';
import 'package:Rem/main.dart';
import 'package:Rem/provider/text_scale_notifier.dart';
import 'package:Rem/screens/permissions_screen/permissions_screen.dart';
import 'package:Rem/screens/permissions_screen/utils/app_permi_handler.dart';
import 'package:Rem/theme/app_theme.dart';
import 'package:Rem/widgets/bottom_nav/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppPermissionHandler.checkAlarmPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
      home: FutureBuilder<bool>(
        future: AppPermissionHandler.checkPermissions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loadingScreen();
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error while checking permissions'));
          } else if (snapshot.hasData) {
            if (snapshot.data!) {
              return FutureBuilder(
                future: Hive.openBox(indiValuesBoxName),
                builder: (context, stacktrace) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _loadingScreen();
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error while loading reminders'));
                  } else if (snapshot.hasData) {
                    return NavigationSection();
                  } else {
                    return const Center(child: Text('Something went wrong'));
                  }
                }
              );
            } else {
              return PermissionScreen();
            }
          } else {
            return const Center(child: Text('Something went wrong'));
          }
        }
      ),
      theme: myTheme,
    );
  }

  Widget _loadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    ); 
  }
}