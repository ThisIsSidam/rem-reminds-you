import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/context_ext.dart';
import '../../../providers/settings_provider.dart';
import '../../shared/dropdown_setting_tile.dart';
import '../../shared/dynamic_subtitle_setting_tile.dart';
import 'no_rush_hours_sheet.dart';

class ReminderPreferencesSection extends ConsumerWidget {
  const ReminderPreferencesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 5),
        Column(
          children: <Widget>[
            _buildQuickPostponeDurationSetting(context, ref),
            _buildNoRushHoursSettings(context, ref),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickPostponeDurationSetting(
    BuildContext context,
    WidgetRef ref,
  ) {
    return DropdownSettingTile<Duration>(
      leading: Icons.more_time,
      title: context.local.settingsPostponeDuration,
      selector: (UserSettingsNotifier p) => p.defaultPostponeDuration,
      dropdownColor: Theme.of(context).scaffoldBackgroundColor,
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
      onChanged: (WidgetRef ref, Duration value) =>
          ref.read(userSettingsProvider).setDefaultPostponeDuration(value),
    );
  }

  Widget _buildNoRushHoursSettings(BuildContext context, WidgetRef ref) {
    return DynamicSubtitleSettingTile<TimeRange>(
      leading: Icons.nightlight,
      title: context.local.settingsNoRushHours,
      selector: (UserSettingsNotifier p) =>
          (from: p.noRushStartTime, to: p.noRushEndTime),
      subtitleBuilder: (BuildContext context, TimeRange? value) => value != null
          ? '${value.from?.format(context)} - ${value.to?.format(context)}'
          : '',
      onTap: (BuildContext context, WidgetRef ref, TimeRange? value) async {
        final newRange = await showNoRushHoursSheet(
          context,
          initialRange: value,
        );
        if (newRange == null || !context.mounted) return;
        await ref.read(userSettingsProvider).setNoRushStartTime(newRange.from!);
        await ref.read(userSettingsProvider).setNoRushEndTime(newRange.to!);
      },
    );
  }
}
