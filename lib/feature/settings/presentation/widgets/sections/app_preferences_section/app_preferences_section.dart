import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/enums/app_language.dart';
import '../../../../../../core/extensions/context_ext.dart';
import '../../../providers/settings_provider.dart';
import '../../shared/dropdown_setting_tile.dart';
import '../../shared/slider_setting_tile.dart';
import '../../shared/switch_setting_tile.dart';

class AppPreferencesSection extends ConsumerWidget {
  const AppPreferencesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 5),
        Column(
          children: <Widget>[
            const ThemeSettingTile(),
            _buildLanguageSetting(context, ref),
            _buildTextScaleSetting(context, ref),
            _buildUseSystemFontTile(context, ref),
          ],
        ),
      ],
    );
  }

  Widget _buildTextScaleSetting(BuildContext context, WidgetRef ref) {
    return SliderSettingTile(
      leading: Icons.format_size,
      title: context.local.settingsTextScale,
      selector: (UserSettingsNotifier p) => p.textScale,
      min: 0.8,
      max: 1.4,
      divisions: 6,
      labelBuilder: (double value) => '${value.toStringAsPrecision(2)}x',
      onChanged: (WidgetRef ref, double val) =>
          ref.read(userSettingsProvider).setTextScale(val),
    );
  }

  Widget _buildLanguageSetting(BuildContext context, WidgetRef ref) {
    return DropdownSettingTile<AppLanguage>(
      leading: Icons.language,
      title: 'Language',
      selector: (UserSettingsNotifier p) => p.language,
      items: AppLanguage.values
          .map(
            (AppLanguage lan) => DropdownMenuItem<AppLanguage>(
              value: lan,
              child: Text(lan.label),
            ),
          )
          .toList(),
      onChanged: (WidgetRef ref, AppLanguage value) =>
          ref.read(userSettingsProvider).setLanguage(value),
    );
  }

  Widget _buildUseSystemFontTile(BuildContext context, WidgetRef ref) {
    return SwitchSettingTile(
      leading: Icons.language,
      title: 'Use system font',
      selector: (UserSettingsNotifier p) => p.useSystemFont,
      onChanged: (WidgetRef ref, bool value) =>
          ref.read(userSettingsProvider).setUseSystemFont(value),
    );
  }
}

class ThemeSettingTile extends ConsumerWidget {
  const ThemeSettingTile({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserSettingsNotifier settingsNotifier = ref.read(
      userSettingsProvider,
    );
    final ThemeMode themeMode = ref.watch(
      userSettingsProvider.select((s) => s.themeMode),
    );
    return ListTile(
      leading: Icon(Icons.brightness_medium, color: context.colors.primary),
      title: Text(
        context.local.settingsTheme,
        style: context.texts.titleMedium,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.system
                  ? Icons.brightness_auto
                  : Icons.brightness_auto_outlined,
            ),
            color: themeMode == ThemeMode.system
                ? context.colors.primary
                : null,
            onPressed: () {
              settingsNotifier.setThemeMode(ThemeMode.system);
            },
          ),
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.light
                  ? Icons.light_mode
                  : Icons.light_mode_outlined,
            ),
            color: themeMode == ThemeMode.light ? context.colors.primary : null,
            onPressed: () {
              settingsNotifier.setThemeMode(ThemeMode.light);
            },
          ),
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.dark_mode_outlined,
            ),
            color: themeMode == ThemeMode.dark ? context.colors.primary : null,
            onPressed: () {
              settingsNotifier.setThemeMode(ThemeMode.dark);
            },
          ),
        ],
      ),
    );
  }
}
