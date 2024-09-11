import 'package:Rem/pages/settings_screen/utils/new_reminder_settings/setting_tiles.dart';
import 'package:flutter/material.dart';

class NewReminderSection extends StatelessWidget {
  const NewReminderSection({super.key});

  @override
  Widget build(BuildContext context) {

    final settingTiles = SettingTiles(context: context);

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
              settingTiles.getDefDueDateTimeTile(),
              SizedBox(height: 10),
              settingTiles.getDefRepeatIntervalTile(),
              SizedBox(height: 10,),
              settingTiles.getQuickTimeTableTile(),
              SizedBox(height: 10,),
              settingTiles.getRepeatDurationTableTile()
            ],
          )
        ],
      ), 
    );
  }

  

}