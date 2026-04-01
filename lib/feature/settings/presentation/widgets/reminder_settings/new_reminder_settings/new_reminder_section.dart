import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/context_ext.dart';
import '../../../providers/settings_provider.dart';
import '../../shared/dynamic_subtitle_setting_tile.dart';
import '../../shared/standard_setting_tile.dart';
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
            _buildQuickTimeTableTile(context, ref),
            _buildSnoozeOptionsTile(context, ref),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultLeadDurationTile(BuildContext context, WidgetRef ref) {
    return DynamicSubtitleSettingTile<Duration>(
      leading: Icons.add,
      title: context.local.settingsDefaultLeadDuration,
      selector: (UserSettingsNotifier p) => p.defaultLeadDuration,
      subtitleBuilder: (BuildContext context, Duration? value) =>
          value?.pretty(tersity: DurationTersity.minute) ?? '',
      onTap: (BuildContext context, WidgetRef ref, Duration? value) async {
        final Duration? newDur = await showDefaultLeadDurationSheet(
          context,
          initialDuration: value ?? Duration.zero,
        );
        if (newDur != null) {
          await ref.read(userSettingsProvider).setDefaultLeadDuration(newDur);
        }
      },
    );
  }

  Widget _buildDefaultAutoSnoozeDurationTile(
    BuildContext context,
    WidgetRef ref,
  ) {
    return DynamicSubtitleSettingTile<Duration>(
      leading: Icons.snooze,
      title: context.local.settingsDefaultAutoSnoozeDuration,
      selector: (UserSettingsNotifier p) => p.defaultAutoSnoozeDuration,
      subtitleBuilder: (BuildContext context, Duration? value) => value != null
          ? context.local.settingsEvery(
              value.pretty(tersity: DurationTersity.minute),
            )
          : '',
      onTap: (BuildContext context, WidgetRef ref, Duration? value) async {
        final Duration? newDur = await showDefaultAutoSnoozeDurationSheet(
          context,
          initialDuration: value ?? Duration.zero,
        );
        if (newDur != null) {
          await ref
              .read(userSettingsProvider)
              .setDefaultAutoSnoozeDuration(newDur);
        }
      },
    );
  }

  Widget _buildQuickTimeTableTile(BuildContext context, WidgetRef ref) {
    return StandardSettingTile(
      leading: Icons.table_chart_outlined,
      title: context.local.settingsQuickTimeTable,
      onTap: () async {
        final settings = ref.read(userSettingsProvider);
        final QuickTimeData initialData = (
          setDateTimes: <int, DateTime>{
            0: settings.quickTimeSetOption1,
            1: settings.quickTimeSetOption2,
            2: settings.quickTimeSetOption3,
            3: settings.quickTimeSetOption4,
          },
          editDurations: <int, Duration>{
            4: settings.quickTimeEditOption1,
            5: settings.quickTimeEditOption2,
            6: settings.quickTimeEditOption3,
            7: settings.quickTimeEditOption4,
            8: settings.quickTimeEditOption5,
            9: settings.quickTimeEditOption6,
            10: settings.quickTimeEditOption7,
            11: settings.quickTimeEditOption8,
          },
        );

        final QuickTimeData? newData = await showQuickTimeTableSheet(
          context,
          initialData: initialData,
        );

        if (newData != null) {
          await settings.setQuickTimeSetOption1(newData.setDateTimes[0]!);
          await settings.setQuickTimeSetOption2(newData.setDateTimes[1]!);
          await settings.setQuickTimeSetOption3(newData.setDateTimes[2]!);
          await settings.setQuickTimeSetOption4(newData.setDateTimes[3]!);

          await settings.setQuickTimeEditOption1(newData.editDurations[4]!);
          await settings.setQuickTimeEditOption2(newData.editDurations[5]!);
          await settings.setQuickTimeEditOption3(newData.editDurations[6]!);
          await settings.setQuickTimeEditOption4(newData.editDurations[7]!);
          await settings.setQuickTimeEditOption5(newData.editDurations[8]!);
          await settings.setQuickTimeEditOption6(newData.editDurations[9]!);
          await settings.setQuickTimeEditOption7(newData.editDurations[10]!);
          await settings.setQuickTimeEditOption8(newData.editDurations[11]!);
        }
      },
    );
  }

  Widget _buildSnoozeOptionsTile(BuildContext context, WidgetRef ref) {
    return StandardSettingTile(
      leading: Icons.snooze_outlined,
      title: context.local.settingsSnoozeOptions,
      onTap: () async {
        final settings = ref.read(userSettingsProvider);
        final Map<int, Duration> initialDurations = <int, Duration>{
          0: settings.autoSnoozeOption1,
          1: settings.autoSnoozeOption2,
          2: settings.autoSnoozeOption3,
          3: settings.autoSnoozeOption4,
          4: settings.autoSnoozeOption5,
          5: settings.autoSnoozeOption6,
        };

        final Map<int, Duration>? newDurations = await showSnoozeOptionsSheet(
          context,
          initialDurations: initialDurations,
        );

        if (newDurations != null) {
          await settings.setAutoSnoozeOption1(newDurations[0]!);
          await settings.setAutoSnoozeOption2(newDurations[1]!);
          await settings.setAutoSnoozeOption3(newDurations[2]!);
          await settings.setAutoSnoozeOption4(newDurations[3]!);
          await settings.setAutoSnoozeOption5(newDurations[4]!);
          await settings.setAutoSnoozeOption6(newDurations[5]!);
        }
      },
    );
  }
}
