enum AppRoute {
  dashboard('/dashboard'),
  reminder('/reminder'),
  permissions('/permissions'),
  splash('/splash'),
  settings('/settings'),
  settingsPersonalization('/settings/personalization'),
  settingsReminder('/settings/reminder'),
  settingsAdvanced('/settings/advanced'),
  settingsNotificationHelp('/settings/notification_help');

  const AppRoute(this.path);
  final String path;
}
