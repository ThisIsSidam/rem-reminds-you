import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/screens/settings_screen/sections/new_reminder_settings/default_auto_snooze_duration_modal.dart';
import 'package:Rem/screens/settings_screen/sections/new_reminder_settings/default_lead_duration_modal.dart';
import 'package:Rem/screens/settings_screen/sections/new_reminder_settings/quick_time_table_modal.dart';
import 'package:Rem/screens/settings_screen/sections/new_reminder_settings/snooze_options_modal.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';

class NewReminderSection extends StatelessWidget {
  const NewReminderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "New Reminder",
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Colors.white),
          ),
          SizedBox(height: 5),
          Column(
            children: [
              SizedBox(height: 10),
              _buildDefaultLeadDurationTile(context),
              SizedBox(height: 10),
              _buildDefaultAutoSnoozeDurationTile(context),
              SizedBox(
                height: 10,
              ),
              _buildQuickTimeTableTile(context),
              SizedBox(
                height: 10,
              ),
              _buildSnoozeOptionsTile(context),
              SizedBox(height: 20),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDefaultLeadDurationTile(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        final Duration dur =
            UserDB.getSetting(SettingOption.DueDateAddDuration);
        final String durString = dur.pretty(tersity: DurationTersity.minute);

        return ListTileTheme(
          data: Theme.of(context).listTileTheme,
          child: ListTile(
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
            trailing: Text(
              durString,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultAutoSnoozeDurationTile(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        final Duration dur =
            UserDB.getSetting(SettingOption.RepeatIntervalFieldValue);
        final String durString =
            "Every " + dur.pretty(tersity: DurationTersity.minute);

        return ListTileTheme(
          data: Theme.of(context).listTileTheme,
          child: ListTile(
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
            trailing: Text(
              durString,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickTimeTableTile(BuildContext context) {
    return ListTileTheme(
      data: Theme.of(context).listTileTheme,
      child: ListTile(
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
      ),
    );
  }

  Widget _buildSnoozeOptionsTile(BuildContext context) {
    return ListTileTheme(
      data: Theme.of(context).listTileTheme,
      child: ListTile(
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
      ),
    );
  }
}
