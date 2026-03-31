import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/context_ext.dart';
import '../../../providers/settings_provider.dart';
import '../../shared/standard_setting_tile.dart';
import '../../shared/subtitle_setting_tile.dart';
import 'default_auto_snooze_duration_modal.dart';
import 'default_lead_duration_modal.dart';
import 'quick_time_table_modal.dart';
import 'snooze_options_modal.dart';

class NewReminderSection extends ConsumerWidget {
  const NewReminderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.near_me, color: Colors.transparent),
          title: Text(
            context.local.settingsNewReminder,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Column(
          children: <Widget>[
            _buildDefaultLeadDurationTile(context, ref),
            _buildDefaultAutoSnoozeDurationTile(context, ref),
            _buildQuickTimeTableTile(context),
            _buildSnoozeOptionsTile(context),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultLeadDurationTile(BuildContext context, WidgetRef ref) {
    return SubtitleSettingTile<Duration>(
      leading: Icons.add,
      title: context.local.settingsDefaultLeadDuration,
      selector: (UserSettingsNotifier p) => p.defaultLeadDuration,
      subtitleBuilder: (BuildContext context, Duration? value) =>
          value?.pretty(tersity: DurationTersity.minute) ?? '',
      minVerticalPadding: 20,
      onTap: (BuildContext context, WidgetRef ref, Duration? value) async {
        await showModalBottomSheet<void>(
          isScrollControlled: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 5,
          context: context,
          builder: (BuildContext context) => const DefaultLeadDurationModal(),
        );
      },
    );
  }

  Widget _buildDefaultAutoSnoozeDurationTile(
    BuildContext context,
    WidgetRef ref,
  ) {
    return SubtitleSettingTile<Duration>(
      leading: Icons.snooze,
      title: context.local.settingsDefaultAutoSnoozeDuration,
      selector: (UserSettingsNotifier p) => p.defaultAutoSnoozeDuration,
      subtitleBuilder: (BuildContext context, Duration? value) => value != null
          ? context.local.settingsEvery(
              value.pretty(tersity: DurationTersity.minute),
            )
          : '',
      minVerticalPadding: 20,
      onTap: (BuildContext context, WidgetRef ref, Duration? value) async {
        await showModalBottomSheet<void>(
          isScrollControlled: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 5,
          context: context,
          builder: (BuildContext context) =>
              const DefaultAutoSnoozeDurationModal(),
        );
      },
    );
  }

  Widget _buildQuickTimeTableTile(BuildContext context) {
    return StandardSettingTile(
      leading: Icons.table_chart_outlined,
      title: context.local.settingsQuickTimeTable,
      onTap: () => showModalBottomSheet<void>(
        isScrollControlled: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 5,
        context: context,
        builder: (BuildContext context) => const QuickTimeTableModal(),
      ),
    );
  }

  Widget _buildSnoozeOptionsTile(BuildContext context) {
    return StandardSettingTile(
      leading: Icons.snooze_outlined,
      title: context.local.settingsSnoozeOptions,
      onTap: () async {
        await showModalBottomSheet<void>(
          isScrollControlled: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 5,
          context: context,
          builder: (BuildContext context) => const SnoozeOptionsModal(),
        );
      },
    );
  }
}
