import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import 'app/theme/color_schemes.dart';
import 'app/theme/theme.dart';
import 'feature/app_startup/presentation/screens/splash_screen.dart';
import 'feature/permissions/domain/app_permi_handler.dart';
import 'feature/settings/presentation/providers/settings_provider.dart';
import 'l10n/app_localizations.dart';
import 'main.dart';
import 'router/route_builder.dart';
import 'shared/utils/logger/app_logger.dart';

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
    AppLogger.i('App Built');
    final (ThemeMode, double) settings = ref.watch(
      userSettingsProvider.select(
        (UserSettingsNotifier p) => (p.themeMode, p.textScale),
      ),
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
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            navigatorKey: navigatorKey,
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(settings.$2)),
                child: child!,
              );
            },
            routes: routeBuilder(),
            home: const SplashScreen(),
            themeMode: settings.$1,
            theme: getLightTheme(lightColorScheme),
            darkTheme: getDarkTheme(darkColorScheme, settings.$1),
          ),
        );
      },
    );
  }
}
