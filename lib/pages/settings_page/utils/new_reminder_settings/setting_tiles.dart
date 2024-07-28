import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/utils/functions/datetime_methods.dart';
import 'package:Rem/pages/settings_page/utils/new_reminder_settings/default_due_datetime_modal.dart';
import 'package:Rem/pages/settings_page/utils/new_reminder_settings/default_due_repeat_interval_modal.dart';
import 'package:Rem/pages/settings_page/utils/new_reminder_settings/quick_time_table_modal.dart';
import 'package:flutter/material.dart';

class SettingTiles {
  BuildContext context;

  SettingTiles({
    required this.context
  });

  Widget _settingTile({
    required String label,
    required Function() onTap,
    String? trailing
  }) {
    return ListTile(
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: BorderSide(
          color: Colors.white
        )
      ),
      minTileHeight: 20,
      onTap: onTap,
      trailing: trailing == null ? null : Text(
        trailing,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget getDefDueDateTimeTile() {
    final Duration dur = UserDB.getSetting(SettingOption.DueDateAddDuration);
    final String durString = formatDuration(dur);

    return _settingTile(
      label: "Default Due Date Time",
      trailing: durString,
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.white10,
          elevation: 5,
          context: context,
          builder: (context) {
            return DefaultDueDatetimeModal();
          }
        );
      },
    );
  }

  Widget getDefRepeatIntervalTile() {
    final Duration dur = UserDB.getSetting(SettingOption.RepeatIntervalFieldValue);
    final String durString = "Every " + formatDuration(dur);

    return _settingTile(
      label: "Default Repeat Interval", 
      trailing: durString,
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.white10,
          elevation: 5,
          context: context,
          builder: (context) {
            return DefaultRepeatIntervalModal();
          }
        );
      }
    );
  }

  Widget getQuickTimeTableTile() {

    return _settingTile(
      label: "Quick Time Table", 
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.white10,
          elevation: 5,
          context: context,
          builder: (context) {
            return QuickTimeTableModal();
          }
        );
      }
    );
  }

}