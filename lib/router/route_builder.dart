import 'package:flutter/material.dart';

import '../feature/agenda/presentation/screens/agenda_screen.dart';
import '../feature/app_startup/presentation/screens/splash_screen.dart';
import '../feature/home/presentation/screens/dashboard_screen.dart';
import '../feature/permissions/presentation/screens/permissions_screen.dart';
import '../feature/reminder/presentation/screens/reminder_screen.dart';
import '../feature/settings/presentation/screens/settings_screen.dart';
import 'app_routes.dart';

Map<String, WidgetBuilder> routeBuilder() {
  return <String, WidgetBuilder>{
    AppRoute.dashboard.path: (_) => const DashboardScreen(),
    AppRoute.agenda.path: (_) => const AgendaScreen(),
    AppRoute.reminder.path: (_) => const ReminderScreen(),
    AppRoute.permissions.path: (_) => const PermissionScreen(),
    AppRoute.splash.path: (_) => const SplashScreen(),
    AppRoute.settings.path: (_) => const SettingsScreen(),
  };
}
