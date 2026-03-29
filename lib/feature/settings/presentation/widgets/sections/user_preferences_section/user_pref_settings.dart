import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/context_ext.dart';
import '../../../../../../core/services/notification_service/notification_service.dart';
import '../../../../../../shared/utils/extensions/string_ext.dart';
import '../../../../../../shared/utils/misc_methods.dart';
import '../../../providers/settings_provider.dart';
import 'no_rush_hours_sheet.dart';

class UserPreferenceSection extends HookWidget {
  const UserPreferenceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final MenuController controller = useMemoized(MenuController.new);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 5),
        Column(
          children: <Widget>[
            _buildThemeSetting(context, controller),
            _buildTextScaleSetting(context),
            _buildQuickPostponeDurationSetting(context),
            _buildNoRushHoursSettings(context),
            _buildAgendaTimeTile(context),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeSetting(BuildContext context, MenuController controller) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
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
      },
    );
  }

  Widget _buildTextScaleSetting(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.format_size),
      title: Text(
        context.local.settingsTextScale,
        style: context.texts.titleMedium,
      ),
      subtitle: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final double textScale = ref.watch(
            userSettingsProvider.select(
              (UserSettingsNotifier p) => p.textScale,
            ),
          );
          return Row(
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
          );
        },
      ),
    );
  }

  Widget _buildQuickPostponeDurationSetting(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.more_time),
      title: Text(
        context.local.settingsPostponeDuration,
        style: context.texts.titleMedium,
      ),
      trailing: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final Duration currentDuration = ref
              .watch(userSettingsProvider)
              .defaultPostponeDuration;
          return DropdownButton<Duration>(
            dropdownColor: Theme.of(context).scaffoldBackgroundColor,
            underline: const SizedBox(),
            padding: const EdgeInsets.only(left: 8, right: 4),
            iconSize: 20,
            style: context.texts.bodyMedium,
            borderRadius: BorderRadius.circular(12),
            value: currentDuration,
            items: <DropdownMenuItem<Duration>>[
              DropdownMenuItem<Duration>(
                value: const Duration(minutes: 15),
                child: Text(context.local.settings15Min),
              ),
              DropdownMenuItem<Duration>(
                value: const Duration(minutes: 30),
                child: Text(context.local.settings30Min),
              ),
              DropdownMenuItem<Duration>(
                value: const Duration(minutes: 45),
                child: Text(context.local.settings45Min),
              ),
              DropdownMenuItem<Duration>(
                value: const Duration(hours: 1),
                child: Text(context.local.settings1Hour),
              ),
              DropdownMenuItem<Duration>(
                value: const Duration(hours: 2),
                child: Text(context.local.settings2Hours),
              ),
            ],
            onChanged: (Duration? value) {
              value ??= currentDuration;
              ref.read(userSettingsProvider).setDefaultPostponeDuration(value);
            },
          );
        },
      ),
    );
  }

  Widget _buildNoRushHoursSettings(BuildContext context) {
    return ListTile(
      onTap: () async {
        await showModalBottomSheet<void>(
          isScrollControlled: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 5,
          context: context,
          builder: (BuildContext context) => const NoRushHoursSheet(),
        );
      },
      leading: const Icon(Icons.nightlight),
      title: Text(
        context.local.settingsNoRushHours,
        style: context.texts.titleMedium,
      ),
      subtitle: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final TimeOfDay noRushStartTime = ref
              .watch(userSettingsProvider)
              .noRushStartTime;
          final TimeOfDay noRushEndTime = ref
              .watch(userSettingsProvider)
              .noRushEndTime;
          return Text(
            // ignore: lines_longer_than_80_chars
            '${noRushStartTime.format(context)} - ${noRushEndTime.format(context)}',
            style: context.texts.bodySmall,
          );
        },
      ),
    );
  }

  Widget _buildAgendaTimeTile(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final TimeOfDay defaultAgendaTime = ref
            .watch(userSettingsProvider)
            .defaultAgendaTime;
        return ListTile(
          onTap: () async {
            final pickedTime = await showTimePicker(
              context: context,
              initialTime: defaultAgendaTime,
            );
            if (pickedTime == null) return;

            await ref
                .read(userSettingsProvider)
                .setDefaultAgendaTime(pickedTime);

            // Update the schedule
            final agendaDateTime = MiscMethods.getAgendaDateTime(pickedTime);
            await NotificationController.scheduleAgenda(agendaDateTime);
          },
          leading: const Icon(Icons.view_agenda),
          title: Text('When to show Agenda?', style: context.texts.titleMedium),
          subtitle: Text(
            defaultAgendaTime.format(context),
            style: context.texts.bodySmall,
          ),
        );
      },
    );
  }
}
