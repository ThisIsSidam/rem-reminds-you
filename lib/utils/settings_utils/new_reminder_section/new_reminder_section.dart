import 'package:Rem/utils/settings_utils/new_reminder_section/setting_tiles.dart';
import 'package:flutter/material.dart';

class NewReminderSection extends StatelessWidget {
  const NewReminderSection({super.key});

  @override
  Widget build(BuildContext context) {

    final settingTiles = SettingTiles(context: context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "New Reminder",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 5),
          Column(
            children: [
              SizedBox(height: 10),
              settingTiles.getDefDueDateTimeTile(),
              SizedBox(height: 10),
              settingTiles.getDefRepeatIntervalTile(),
            ],
          )
        ],
      ), 
    );
  }

  

}