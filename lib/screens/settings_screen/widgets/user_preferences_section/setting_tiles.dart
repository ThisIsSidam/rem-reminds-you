import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/database/settings/swipe_actions.dart';
import 'package:Rem/screens/settings_screen/widgets/user_preferences_section/swipe_to_left_action_sheet.dart';
import 'package:Rem/screens/settings_screen/widgets/user_preferences_section/swipe_to_right_action_sheet.dart';
import 'package:flutter/material.dart';

class SettingTiles {
  BuildContext context;
  void Function() refreshPage;

  SettingTiles({
    required this.context,
    required this.refreshPage
  });

  Widget _settingTile({
    required String label,
    Widget? subtitle,
    void Function()? onTap,
  }) {
    return ListTileTheme(
      data: Theme.of(context).listTileTheme,
      child: ListTile(
        title: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        minTileHeight: 20,
        subtitle: subtitle,
        onTap: onTap,
      ),
    );
  }

  void _showModal(Widget child) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 5,
      context: context,
      builder: (context) {
        return child;
    });
    refreshPage();
  }

  Widget getTitleParsingOption() {
    return _settingTile(
        label: "Prompt before setting time from title",
        // trailing: ToggleButtons(
        //   children: ,
        //   isSelected: isSelected
        // )
        subtitle:
            Text("Coming Soon", style: Theme.of(context).textTheme.bodySmall));
  }

  Widget getSlideToLeftActionsSetting() {
    SwipeAction action =
        UserDB.getSetting(SettingOption.HomeTileSlideAction_ToLeft);

    return _settingTile(
        label: "Swipe to Left Actions",
        subtitle:
            Text(action.toString(), style: Theme.of(context).textTheme.bodySmall),
        onTap: () => _showModal(SwipeToLeftActionSheet()));
  }

  Widget getSlideToRightActionsSetting() {
    SwipeAction action =
        UserDB.getSetting(SettingOption.HomeTileSlideAction_ToRight);

    return _settingTile(
        label: "Swipe to Right Actions",
        subtitle:
            Text(action.toString(), style: Theme.of(context).textTheme.bodySmall),
        onTap: () => _showModal(SwipeToRightActionSheet()));
  }
}
