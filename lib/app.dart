import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import 'core/theme/app_theme.dart';
import 'feature/app_startup/presentation/providers/app_startup_provider.dart';
import 'feature/app_startup/presentation/providers/initial_screen_provider.dart';
import 'feature/app_startup/presentation/screens/splash_screen.dart';
import 'feature/app_startup/presentation/widgets/splash_error.dart';
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
    ref.listen(appStartupProvider, (_, __) {});
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

        return ToastificationWrapper(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(settings.$2),
                ),
                child: child!,
              );
            },
            home: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final String? screen = ref.watch(initialScreenNotifierProvider);
                if (screen == null) {
                  return const SplashScreen();
                } else if (screen == 'Home') {
                  return const DashboardScreen();
                } else if (screen == 'Permissions') {
                  return const PermissionScreen();
                } else {
                  return const SplashErrorWidget();
                }
              },
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
          ),
        );
      },
    );
  }
}
