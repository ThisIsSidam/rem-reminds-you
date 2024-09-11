import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/screens/settings_screen/utils/new_reminder_settings/default_due_datetime_modal.dart';
import 'package:Rem/screens/settings_screen/utils/new_reminder_settings/default_due_repeat_interval_modal.dart';
import 'package:Rem/screens/settings_screen/utils/new_reminder_settings/quick_time_table_modal.dart';
import 'package:Rem/screens/settings_screen/utils/new_reminder_settings/repeat_duration_table_modal.dart';
import 'package:Rem/utils/datetime_methods.dart';
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
    return ListTileTheme(
      data: Theme.of(context).listTileTheme,
      child: ListTile(
        title: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        minTileHeight: 20,
        onTap: onTap,
        trailing: trailing == null ? null : Text(
          trailing,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  void _showModal(Widget child) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 5,
      context: context,
      builder: (context) {
        return child;
      }
    );
  }

  Widget getDefDueDateTimeTile() {
    final Duration dur = UserDB.getSetting(SettingOption.DueDateAddDuration);
    final String durString = formatDuration(dur);

    return _settingTile(
      label: "Default Due Date Time",
      trailing: durString,
      onTap: () => _showModal(DefaultDueDatetimeModal()),
    );
  }

  Widget getDefRepeatIntervalTile() {
    final Duration dur = UserDB.getSetting(SettingOption.RepeatIntervalFieldValue);
    final String durString = "Every " + formatDuration(dur);

    return _settingTile(
      label: "Default Repeat Interval", 
      trailing: durString,
      onTap: () => _showModal(DefaultRepeatIntervalModal())
    );
  }

  Widget getQuickTimeTableTile() {

    return _settingTile(
      label: "Quick Time Table", 
      onTap: () => _showModal(QuickTimeTableModal())
    );
  }

  Widget getRepeatDurationTableTile() {
    return _settingTile(
      label: "Repeat Duration Table", 
      onTap: () => _showModal(RepeatDurationTableModal())
    );
  }

}