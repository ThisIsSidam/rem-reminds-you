enum AppRoute {
  agenda('/agenda'),
  dashboard('/dashboard'),
  reminder('/reminder'),
  permissions('/permissions'),
  splash('/splash'),
  settings('/settings');

  const AppRoute(this.path);
  final String path;
}
