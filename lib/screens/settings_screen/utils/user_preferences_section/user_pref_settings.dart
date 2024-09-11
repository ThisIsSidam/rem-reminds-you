import 'package:Rem/screens/settings_screen/utils/user_preferences_section/setting_tiles.dart';
import 'package:flutter/material.dart';

class UserPreferenceSection extends StatelessWidget {
  const UserPreferenceSection({super.key});

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
            "User Preferences",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Colors.white
            ),
          ),
          SizedBox(height: 5),
          Column(
            children: [
              SizedBox(height: 10),
              settingTiles.getTitleParsingOption(),
              SizedBox(height: 10),
              settingTiles.getSlideActionsSetting(),
              SizedBox(height: 10,)
            ],
          )
        ],
      ), 
    );
  }

  

}