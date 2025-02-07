import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'feature/home/presentation/screens/dashboard_screen.dart';
import 'feature/permissions/domain/app_permi_handler.dart';
import 'feature/permissions/presentation/screens/permissions_screen.dart';
import 'feature/settings/presentation/providers/settings_provider.dart';
import 'main.dart';
import 'shared/utils/logger/global_logger.dart';

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
    final (ThemeMode, double) settings = ref.watch(
      userSettingsProvider
          .select((UserSettingsNotifier p) => (p.themeMode, p.textScale)),
    );

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          lightColorScheme = appColorScheme;
          darkColorScheme = appDarkColorScheme;
        }

        return MaterialApp(
          navigatorKey: navigatorKey,
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(settings.$2),
              ),
              child: child!,
            );
          },
          home: _buildPermissionScreenLayer(
            child: const DashboardScreen(),
          ),
          themeMode: settings.$1,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            appBarTheme: const AppBarTheme(
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
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark, // for iOS
              ),
            ),
            cupertinoOverrideTheme: CupertinoThemeData(
              brightness: settings.$1 == ThemeMode.light
                  ? Brightness.light
                  : Brightness.dark,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionScreenLayer({required Widget child}) {
    return FutureBuilder<bool>(
      future: AppPermissionHandler.checkPermissions(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        gLogger.i('Checking for permissions');
        if (snapshot.connectionState == ConnectionState.waiting) {
          gLogger.i('Loading..');
          return _loadingScreen();
        } else if (snapshot.hasError) {
          gLogger.e(
            'Go error checking for permissions',
            error: snapshot.error,
            stackTrace: snapshot.stackTrace,
          );
          return const Center(child: Text('Error while checking permissions'));
        } else if (snapshot.hasData) {
          if (snapshot.data!) {
            gLogger.i('Permissions granted');
            return child;
          } else {
            gLogger.i('Permissions not granted');
            return const PermissionScreen();
          }
        } else {
          gLogger.e(
            'Something weird happened in permissionsLayer',
            error: snapshot.error,
            stackTrace: snapshot.stackTrace,
          );
          return const Center(child: Text('Something went wrong'));
        }
      },
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
