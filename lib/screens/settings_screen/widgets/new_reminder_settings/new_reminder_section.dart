import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/screens/settings_screen/widgets/new_reminder_settings/default_due_datetime_modal.dart';
import 'package:Rem/screens/settings_screen/widgets/new_reminder_settings/default_due_repeat_interval_modal.dart';
import 'package:Rem/screens/settings_screen/widgets/new_reminder_settings/quick_time_table_modal.dart';
import 'package:Rem/screens/settings_screen/widgets/new_reminder_settings/repeat_duration_table_modal.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:flutter/material.dart';

class NewReminderSection extends StatelessWidget {
  const NewReminderSection({super.key});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "New Reminder",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Colors.white
            ),
          ),
          SizedBox(height: 5),
          Column(
            children: [
              SizedBox(height: 10),
              _buildDefDueDateTimeTile(context),
              SizedBox(height: 10),
              _buildDefRepeatIntervalTile(context),
              SizedBox(height: 10,),
              _buildQuickTimeTableTile(context),
              SizedBox(height: 10,),
              _buildRepeatDurationTableTile(context),
              SizedBox(height:20),
            ],
          )
        ],
      ), 
    );
  }

  Widget _buildDefDueDateTimeTile(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        final Duration dur = UserDB.getSetting(SettingOption.DueDateAddDuration);
        final String durString = formatDuration(dur);

        return ListTileTheme(
          data: Theme.of(context).listTileTheme,
          child: ListTile(
            title: Text(
              "Default Due Date Time",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            minVerticalPadding: 20,
            onTap: () async {
              await showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 5,
                context: context,
                builder: (context) => DefaultDueDatetimeModal(),
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

  Widget _buildDefRepeatIntervalTile(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        final Duration dur = UserDB.getSetting(SettingOption.RepeatIntervalFieldValue);
        final String durString = "Every " + formatDuration(dur);

        return ListTileTheme(
          data: Theme.of(context).listTileTheme,
          child: ListTile(
            title: Text(
              "Default Repeat Interval",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            minVerticalPadding: 20,
            onTap: () async {
              await showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 5,
                context: context,
                builder: (context) => DefaultRepeatIntervalModal(),
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
          "Quick Time Table",
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

  Widget _buildRepeatDurationTableTile(BuildContext context) {
    return ListTileTheme(
      data: Theme.of(context).listTileTheme,
      child: ListTile(
        title: Text(
          "Repeat Duration Table",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        minVerticalPadding: 20,
        onTap: () {
          showModalBottomSheet(
            isScrollControlled: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 5,
            context: context,
            builder: (context) => RepeatDurationTableModal(),
          );
        },
      ),
    );
  }

}
