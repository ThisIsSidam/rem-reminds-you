import 'package:flutter/material.dart';

import '../feature/app_startup/presentation/screens/splash_screen.dart';
import '../feature/home/presentation/screens/dashboard_screen.dart';
import '../feature/home/presentation/screens/home_screen.dart';
import '../feature/permissions/presentation/screens/permissions_screen.dart';
import '../feature/settings/presentation/screens/settings_screen.dart';
import 'app_routes.dart';

Map<String, WidgetBuilder> routeBuilder() {
  return <String, WidgetBuilder>{
    AppRoute.home.path: (BuildContext context) => const HomeScreen(),
    AppRoute.dashboard.path: (BuildContext context) => const DashboardScreen(),
    AppRoute.permissions.path: (BuildContext context) =>
        const PermissionScreen(),
    AppRoute.splash.path: (BuildContext context) => const SplashScreen(),
    AppRoute.settings.path: (BuildContext context) => const SettingsScreen(),
  };
}
