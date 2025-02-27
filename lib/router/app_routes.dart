enum AppRoute {
  home('/home'),
  dashboard('/dashboard'),
  permissions('/permissions'),
  splash('splash'),
  settings('settings'),
  ;

  const AppRoute(this.path);
  final String path;
}
