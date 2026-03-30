import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/context_ext.dart';
import '../../../providers/settings_provider.dart';
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
    final Duration currentDuration = ref
        .watch(userSettingsProvider)
        .defaultPostponeDuration;
    return ListTile(
      leading: Icon(Icons.more_time, color: context.colors.primary),
      title: Text(
        context.local.settingsPostponeDuration,
        style: context.texts.titleMedium,
      ),
      trailing: DropdownButton<Duration>(
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
      ),
    );
  }

  Widget _buildNoRushHoursSettings(BuildContext context, WidgetRef ref) {
    final TimeOfDay noRushStartTime = ref
        .watch(userSettingsProvider)
        .noRushStartTime;
    final TimeOfDay noRushEndTime = ref
        .watch(userSettingsProvider)
        .noRushEndTime;
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
      leading: Icon(Icons.nightlight, color: context.colors.primary),
      title: Text(
        context.local.settingsNoRushHours,
        style: context.texts.titleMedium,
      ),
      subtitle: Text(
        '${noRushStartTime.format(context)} - ${noRushEndTime.format(context)}',
        style: context.texts.bodySmall,
      ),
    );
  }
}
