import 'dart:ui';

enum AppLanguage {
  system('System', 'system'),
  english('English', 'en'),
  spanish('Español', 'es');

  const AppLanguage(this.label, this.localeStr);

  final String label;
  final String localeStr;

  static AppLanguage fromString(String locale) => AppLanguage.values.firstWhere(
    (lan) => lan.localeStr == locale,
    orElse: () => .system,
  );

  Locale? get locale {
    if (this == .system) return null;
    return Locale(localeStr);
  }
}
