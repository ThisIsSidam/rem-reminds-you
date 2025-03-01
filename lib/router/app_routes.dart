enum AppRoute {
  home('/home'),
  permissions('/permissions'),
  splash('splash'),
  settings('settings'),
  ;

  const AppRoute(this.path);
  final String path;
}
