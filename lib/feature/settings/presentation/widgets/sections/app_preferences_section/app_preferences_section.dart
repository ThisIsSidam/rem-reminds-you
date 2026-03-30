import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../app/enums/app_language.dart';
import '../../../../../../core/extensions/context_ext.dart';
import '../../../../../../shared/utils/extensions/string_ext.dart';
import '../../../providers/settings_provider.dart';

class AppPreferencesSection extends HookConsumerWidget {
  const AppPreferencesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MenuController controller = useMemoized(MenuController.new);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 5),
        Column(
          children: <Widget>[
            _buildThemeSetting(context, ref, controller),
            _buildLanguageSetting(context, ref),
            _buildTextScaleSetting(context, ref),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeSetting(
    BuildContext context,
    WidgetRef ref,
    MenuController controller,
  ) {
    final UserSettingsNotifier settingsNotifier = ref.read(
      userSettingsProvider,
    );
    final ThemeMode themeMode = ref.watch(userSettingsProvider).themeMode;
    return MenuAnchor(
      controller: controller,
      menuChildren: <Widget>[
        for (final ThemeMode mode in ThemeMode.values)
          MenuItemButton(
            child: Text(mode.name.capitalize()),
            onPressed: () {
              settingsNotifier.setThemeMode(mode);
            },
          ),
      ],
      child: ListTile(
        onTap: () {
          controller.isOpen ? controller.close() : controller.open();
        },
        leading: Icon(
          themeMode == ThemeMode.system
              ? Icons.brightness_6
              : settingsNotifier.themeMode == ThemeMode.dark
              ? Icons.dark_mode
              : Icons.light_mode,
          color: context.colors.primary,
        ),
        title: Text(
          context.local.settingsTheme,
          style: context.texts.titleMedium,
        ),
        subtitle: Text(
          themeMode.name.capitalize(),
          style: context.texts.bodySmall,
        ),
      ),
    );
  }

  Widget _buildTextScaleSetting(BuildContext context, WidgetRef ref) {
    final double textScale = ref.watch(
      userSettingsProvider.select((UserSettingsNotifier p) => p.textScale),
    );
    return ListTile(
      leading: Icon(Icons.format_size, color: context.colors.primary),
      title: Text(
        context.local.settingsTextScale,
        style: context.texts.titleMedium,
      ),
      subtitle: Row(
        children: <Widget>[
          Expanded(
            child: Slider(
              value: textScale,
              min: 0.8,
              max: 1.4,
              divisions: 6,
              onChanged: (double val) {
                ref.read(userSettingsProvider).setTextScale(val);
              },
              inactiveColor: Theme.of(context).colorScheme.secondary,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            '${textScale.toStringAsPrecision(2)}x',
            style: context.texts.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSetting(BuildContext context, WidgetRef ref) {
    final AppLanguage language = ref.watch(userSettingsProvider).language;
    return ListTile(
      leading: Icon(Icons.language, color: context.colors.primary),
      title: Text('Language', style: context.texts.titleMedium),
      trailing: DropdownButton<AppLanguage>(
        dropdownColor: Theme.of(context).cardColor,
        underline: const SizedBox(),
        padding: const EdgeInsets.only(left: 8, right: 4),
        iconSize: 20,
        style: context.texts.bodyMedium,
        borderRadius: BorderRadius.circular(12),
        value: language,
        items: AppLanguage.values
            .map(
              (lan) => DropdownMenuItem<AppLanguage>(
                value: lan,
                child: Text(lan.label),
              ),
            )
            .toList(),
        onChanged: (AppLanguage? value) {
          if (value != null) {
            ref.read(userSettingsProvider).setLanguage(value);
          }
        },
      ),
    );
  }
}
