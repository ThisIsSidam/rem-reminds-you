import 'package:Rem/provider/settings_provider.dart';
import 'package:Rem/provider/text_scale_provider.dart';
import 'package:Rem/utils/extensions/string_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPreferenceSection extends HookWidget {
  const UserPreferenceSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // User Pref is placed at the top in list of sections and would not contain
    // a title widget, it looks weird with one.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5),
        Column(
          children: [
            _buildThemeSetting(context),
            _buildTextScaleSetting(context),
            _buildQuickPostponeDurationSetting(context),
          ],
        )
      ],
    );
  }

  Widget _buildThemeSetting(BuildContext context) {
    final controller = useMemoized(() => MenuController());

    useEffect(() {
      return controller.close;
    }, [controller]);

    return Consumer(builder: (context, ref, child) {
      final settingsNotifier = ref.read(userSettingsProvider.notifier);
      final themeMode = ref.watch(userSettingsProvider).themeMode;
      return MenuAnchor(
        controller: controller,
        menuChildren: [
          for (final mode in ThemeMode.values)
            MenuItemButton(
              child: Text(mode.name.capitalize()),
              onPressed: () {
                settingsNotifier.themeMode = mode;
              },
            )
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
          ),
          title: Text('Theme', style: Theme.of(context).textTheme.titleSmall),
          subtitle: Text(
            themeMode.name.capitalize(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    });
  }

  Widget _buildTextScaleSetting(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.format_size),
      title: Text('Text Scale', style: Theme.of(context).textTheme.titleSmall),
      subtitle: Consumer(builder: (context, ref, child) {
        final textScale = ref.watch(textScaleProvider).textScale;
        return Row(
          children: [
            Expanded(
              child: Slider(
                value: textScale,
                min: 0.8,
                max: 1.4,
                label: '${textScale}x',
                divisions: 6,
                onChanged: (val) {
                  ref.read(textScaleProvider).textScale = val;
                },
                inactiveColor: Theme.of(context).colorScheme.secondary,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              '${textScale.toStringAsPrecision(2)}x',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          ],
        );
      }),
    );
  }

  Widget _buildQuickPostponeDurationSetting(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.more_time),
      title: Text('Postpone Duration',
          style: Theme.of(context).textTheme.titleSmall),
      trailing: Consumer(builder: (context, ref, child) {
        Duration currentDuration =
            ref.watch(userSettingsProvider).defaultPostponeDuration;
        return DropdownButton<Duration>(
            dropdownColor: Theme.of(context).scaffoldBackgroundColor,
            underline: SizedBox(),
            padding: EdgeInsets.only(left: 8, right: 4),
            iconSize: 20,
            style: Theme.of(context).textTheme.bodyMedium,
            borderRadius: BorderRadius.circular(12),
            value: currentDuration,
            items: <DropdownMenuItem<Duration>>[
              DropdownMenuItem<Duration>(
                  value: const Duration(minutes: 15), child: Text('15 min')),
              DropdownMenuItem<Duration>(
                  value: const Duration(minutes: 30), child: Text('30 min')),
              DropdownMenuItem<Duration>(
                  value: const Duration(minutes: 45), child: Text('45 min')),
              DropdownMenuItem<Duration>(
                  value: const Duration(hours: 1), child: Text('1 hour')),
              DropdownMenuItem<Duration>(
                  value: const Duration(hours: 2), child: Text('2 hours')),
            ],
            onChanged: (value) {
              if (value == null) value = currentDuration;
              ref.read(userSettingsProvider).defaultPostponeDuration = value;
            });
      }),
    );
  }
}
