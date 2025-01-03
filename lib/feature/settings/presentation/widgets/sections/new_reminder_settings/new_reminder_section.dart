import 'package:Rem/feature/settings/presentation/providers/settings_provider.dart';
import 'package:Rem/feature/settings/presentation/widgets/sections/new_reminder_settings/default_auto_snooze_duration_modal.dart';
import 'package:Rem/feature/settings/presentation/widgets/sections/new_reminder_settings/default_lead_duration_modal.dart';
import 'package:Rem/feature/settings/presentation/widgets/sections/new_reminder_settings/quick_time_table_modal.dart';
import 'package:Rem/feature/settings/presentation/widgets/sections/new_reminder_settings/snooze_options_modal.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewReminderSection extends ConsumerWidget {
  const NewReminderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.near_me, color: Colors.transparent),
          title: Text(
            "New Reminder",
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        SizedBox(height: 5),
        Column(
          children: [
            _buildDefaultLeadDurationTile(context, ref),
            _buildDefaultAutoSnoozeDurationTile(context, ref),
            _buildQuickTimeTableTile(context),
            _buildSnoozeOptionsTile(context),
          ],
        )
      ],
    );
  }

  Widget _buildDefaultLeadDurationTile(BuildContext context, WidgetRef ref) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        final Duration dur =
            ref.watch(userSettingsProvider).defaultLeadDuration;
        final String durString = dur.pretty(tersity: DurationTersity.minute);

        return ListTile(
          leading: Icon(Icons.add),
          title: Text(
            "Default lead duration",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          minVerticalPadding: 20,
          onTap: () async {
            await showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 5,
              context: context,
              builder: (context) => DefaultLeadDurationModal(),
            );
            setState(() {}); // Refresh the tile after modal is closed
          },
          subtitle: Text(
            durString,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      },
    );
  }

  Widget _buildDefaultAutoSnoozeDurationTile(
      BuildContext context, WidgetRef ref) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        final Duration dur =
            ref.watch(userSettingsProvider).defaultAutoSnoozeDuration;
        final String durString =
            "Every " + dur.pretty(tersity: DurationTersity.minute);

        return ListTile(
          leading: Icon(Icons.snooze),
          title: Text(
            "Default auto snooze duration",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          minVerticalPadding: 20,
          onTap: () async {
            await showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 5,
              context: context,
              builder: (context) => DefaultAutoSnoozeDurationModal(),
            );
            setState(() {}); // Refresh the tile after modal is closed
          },
          subtitle: Text(
            durString,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      },
    );
  }

  Widget _buildQuickTimeTableTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.table_chart_outlined),
      title: Text(
        "Quick time table",
        style: Theme.of(context).textTheme.titleSmall,
      ),
      minVerticalPadding: 20,
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 5,
          context: context,
          builder: (context) => QuickTimeTableModal(),
        );
      },
    );
  }

  Widget _buildSnoozeOptionsTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.snooze_outlined),
      title: Text(
        "Snooze options",
        style: Theme.of(context).textTheme.titleSmall,
      ),
      minVerticalPadding: 20,
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 5,
          context: context,
          builder: (context) => SnoozeOptionsModal(),
        );
      },
    );
  }
}
