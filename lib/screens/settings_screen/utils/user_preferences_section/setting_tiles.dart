import 'package:flutter/material.dart';

class SettingTiles {
  BuildContext context;

  SettingTiles({
    required this.context
  });

  Widget _settingTile({
    required String label,
    Widget? trailing
  }) {
    return ListTileTheme(
      data: Theme.of(context).listTileTheme,
      child: ListTile(
        title: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        minTileHeight: 20,
        trailing: trailing,
      ),
    );
  }

  Widget getTitleParsingOption() {
    return _settingTile(
      label: "Prompt before setting time from title",
      // trailing: ToggleButtons(
      //   children: , 
      //   isSelected: isSelected
      // )
      trailing: Text(
        "Coming Soon",
        style: Theme.of(context).textTheme.bodyMedium
      )
    );
  }

  Widget getSlideActionsSetting() {
    return _settingTile(
      label: "Swipe Actions",
      trailing: Text(
        "Coming Soon",
        style: Theme.of(context).textTheme.bodyMedium
      )
    );
  }
}