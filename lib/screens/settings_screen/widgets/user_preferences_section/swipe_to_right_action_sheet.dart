import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/database/settings/swipe_actions.dart';
import 'package:flutter/material.dart';

class SwipeToRightActionSheet extends StatelessWidget {

  SwipeToRightActionSheet({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          Text("Swipe to Left Actions", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
                const SizedBox(width: 20),
                Text(
                  'Swipe Right',
                  style: Theme.of(context).textTheme.bodyLarge
                ),
                const SizedBox(width: 20),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          StatefulBuilder(
            builder: (context, setState) {

              return Column(
                children: [
                  for (final SwipeAction action in SwipeAction.values) 
                    _buildOptionTile(action, context, setState)
                ],
              );
            }
          )
        ],
      )
    );
  }

  Widget _buildOptionTile(SwipeAction action, BuildContext context, StateSetter setState) {

    SwipeAction selectedAction = UserDB.getSetting(SettingOption.HomeTileSlideAction_ToRight);
  
    return Padding(
      padding: const EdgeInsets.only(
        top: 20, left: 20, right: 20, bottom: 0
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            UserDB.setSetting(
              SettingOption.HomeTileSlideAction_ToRight, 
              action
            );
          });
        },
        child: Row(
          children: [
            Icon(
              Icons.check,
              color: action == selectedAction
              ? Colors.white
              : Colors.transparent
            ),
            const SizedBox(width: 20),
            Text(
              action.toString(),
              style: Theme.of(context).textTheme.bodyMedium
            ),
          ],
        ),
      ),
    );
  }
}