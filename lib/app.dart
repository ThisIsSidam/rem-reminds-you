import 'package:Rem/consts/enums/hive_enums.dart';
import 'package:Rem/main.dart';
import 'package:Rem/provider/settings_provider.dart';
import 'package:Rem/provider/text_scale_provider.dart';
import 'package:Rem/screens/permissions_screen/permissions_screen.dart';
import 'package:Rem/screens/permissions_screen/utils/app_permi_handler.dart';
import 'package:Rem/utils/logger/global_logger.dart';
import 'package:Rem/widgets/bottom_nav/bottom_nav_bar.dart';
import 'package:dynamic_color/dynamic_color.dart';
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
    gLogger.i('App Built');
    double textScale = ref.watch(textScaleProvider).textScale;
    final settings = ref.watch(userSettingsProvider);

    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      ColorScheme lightColorScheme;
      ColorScheme darkColorScheme;

      if (lightDynamic != null && darkDynamic != null) {
        lightColorScheme = lightDynamic.harmonized();
        darkColorScheme = darkDynamic.harmonized();
      } else {
        lightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.blue);
        darkColorScheme = ColorScheme.fromSwatch(
          brightness: Brightness.dark,
        );
      }
      return MaterialApp(
          navigatorKey: navigatorKey,
          builder: (context, child) {
            return MediaQuery(
              child: child!,
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(textScale)),
            );
          },
          home: _buildPermissionScreenLayer(
            child: _buildIndiValuesLayer(
              child: NavigationLayer(),
            ),
          ),
          themeMode: settings.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
          ));
    });
  }

  Widget _buildPermissionScreenLayer({required Widget child}) {
    return FutureBuilder<bool>(
      future: AppPermissionHandler.checkPermissions(),
      builder: (context, snapshot) {
        gLogger.i('Checking for permissions');
        if (snapshot.connectionState == ConnectionState.waiting) {
          gLogger.i('Loading..');
          return _loadingScreen();
        } else if (snapshot.hasError) {
          gLogger.e('Go error checking for permissions',
              error: snapshot.error, stackTrace: snapshot.stackTrace);
          return const Center(child: Text('Error while checking permissions'));
        } else if (snapshot.hasData) {
          if (snapshot.data!) {
            gLogger.i('Permissions granted');
            return child;
          } else {
            gLogger.i('Permissions not granted');
            return PermissionScreen();
          }
        } else {
          gLogger.e('Something weird happened in permissionsLayer',
              error: snapshot.error, stackTrace: snapshot.stackTrace);
          return const Center(child: Text('Something went wrong'));
        }
      },
    );
  }

  Widget _buildIndiValuesLayer({required Widget child}) {
    return FutureBuilder(
        future: Hive.openBox(HiveBoxNames.individualValues.name),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            gLogger.i('Loading..');
            return _loadingScreen();
          } else if (snapshot.hasError) {
            gLogger.i('Error while opening individual values box');
            return const Center(
              child: Text(
                'Error while loading reminders',
              ),
            );
          } else if (snapshot.hasData) {
            return child;
          } else {
            gLogger.i('Something weird happened in individual values layer');
            return const Center(
              child: Text('Something went wrong'),
            );
          }
        });
  }

  Widget _loadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
