enum AppRoute {
  agenda('/agenda'),
  dashboard('/dashboard'),
  reminder('/reminder'),
  permissions('/permissions'),
  splash('/splash'),
  settings('/settings'),
  settingsPersonalization('/settings/personalization'),
  settingsReminder('/settings/reminder'),
  settingsAgenda('/settings/agenda'),
  settingsAdvanced('/settings/advanced'),
  settingsNotificationHelp('/settings/notification_help');

  const AppRoute(this.path);
  final String path;
}
