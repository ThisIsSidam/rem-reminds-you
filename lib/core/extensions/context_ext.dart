import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  TextTheme get texts => theme.textTheme;

  AppLocalizations get local => AppLocalizations.of(this)!;
}
