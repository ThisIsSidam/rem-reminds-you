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
    AppRoute.dashboard.name: (_) => const DashboardScreen(),
    AppRoute.agenda.name: (_) => const AgendaScreen(),
    AppRoute.reminder.name: (_) => const ReminderScreen(),
    AppRoute.permissions.name: (_) => const PermissionScreen(),
    AppRoute.splash.name: (_) => const SplashScreen(),
    AppRoute.settings.name: (_) => const SettingsScreen(),
  };
}
