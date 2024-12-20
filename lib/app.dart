import 'package:Rem/core/enums/hive_enums.dart';
import 'package:Rem/feature/permissions/domain/app_permi_handler.dart';
import 'package:Rem/feature/permissions/presentation/screens/permissions_screen.dart';
import 'package:Rem/feature/settings/presentation/providers/settings_provider.dart';
import 'package:Rem/main.dart';
import 'package:Rem/shared/utils/logger/global_logger.dart';
import 'package:Rem/shared/widgets/bottom_nav/bottom_nav_bar.dart';
import 'package:dynamic_color/dynamic_color.dart';
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
    final (ThemeMode, double) settings = ref
        .watch(userSettingsProvider.select((p) => (p.themeMode, p.textScale)));

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
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(settings.$2),
              ),
            );
          },
          home: _buildPermissionScreenLayer(
            child: _buildIndiValuesLayer(
              child: NavigationLayer(),
            ),
          ),
          themeMode: settings.$1,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light, // for iOS
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark, // for iOS
              ),
            ),
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
