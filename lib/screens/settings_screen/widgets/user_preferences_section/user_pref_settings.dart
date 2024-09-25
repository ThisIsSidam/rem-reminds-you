import 'package:Rem/screens/settings_screen/widgets/user_preferences_section/setting_tiles.dart';
import 'package:flutter/material.dart';

class UserPreferenceSection extends StatelessWidget {
  const UserPreferenceSection({
    super.key,
    required this.refreshPage
  });

  final void Function() refreshPage;

  @override
  Widget build(BuildContext context) {

    final settingTiles = SettingTiles(
      context: context,
      refreshPage: refreshPage
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              "User Preferences",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.primary
              )
            ),
          ),
          SizedBox(height: 5),
          Column(
            children: [
              SizedBox(height: 10),
              settingTiles.getTitleParsingOption(),
              SizedBox(height: 10),
              settingTiles.getSlideToLeftActionsSetting(),
              SizedBox(height: 10,),
              settingTiles.getSlideToRightActionsSetting(),
            ],
          )
        ],
      ), 
    );
  }

  

}