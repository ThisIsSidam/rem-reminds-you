import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/database/settings/swipe_actions.dart';
import 'package:Rem/provider/text_scale_notifier.dart';
import 'package:Rem/screens/settings_screen/widgets/user_preferences_section/swipe_to_left_action_sheet.dart';
import 'package:Rem/screens/settings_screen/widgets/user_preferences_section/swipe_to_right_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPreferenceSection extends StatelessWidget {
  const UserPreferenceSection({
    super.key,});

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
            "User Preferences",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Colors.white
            ),
          ),
          SizedBox(height: 5),
          Column(
            children: [
              SizedBox(height: 10),
              _buildSlideToLeftActionsSetting(context),
              SizedBox(height: 10,),
              _buildSlideToRightActionsSetting(context),
              SizedBox(height: 10),
              _buildTextScaleSetting(context),
              SizedBox(height: 10),
              _buildQuickPostponeDurationSetting(context),
              SizedBox(height: 20,),
            ],
          )
        ],
      ), 
    );
  }

  Widget _buildTextScaleSetting(BuildContext context) {
    return ListTile(
      title: Text(
        'Text Scale',
        style: Theme.of(context).textTheme.titleSmall
      ),
      subtitle: Row(
        children: [
          Text('A', style: TextStyle(color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
            child: Consumer(
              builder: (context, ref, chid) {
                final textScaleNotifier = ref.watch(textScaleProvider);
                return StatefulBuilder(
                  builder: (context, setState) {
                    final List<double> _scaleValues = [
                      0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4
                    ];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_scaleValues.length, (index) => 
                        Flexible(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                textScaleNotifier.changeTextScale(_scaleValues[index]);
                              });
                            },
                            child: SizedBox(
                              width: 8 * _scaleValues[index],
                              height: 8 * _scaleValues[index],
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: textScaleNotifier.textScale == _scaleValues[index]
                                    ? Theme.of(context).primaryColor 
                                    : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      )
                    );
                  }
                );
              }
            ),
          ),
          const SizedBox(width: 10),
          Text('A', style: TextStyle(color: Colors.white, fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildQuickPostponeDurationSetting(BuildContext context) {
    Duration currentDuration = UserDB.getSetting(SettingOption.SlideActionPostponeDuration);
    return ListTile(
      title: Text(
        'Postpone Duration',
        style: Theme.of(context).textTheme.titleSmall
      ),
      trailing: StatefulBuilder(
        builder: (context, setState) {
          return DropdownButton<Duration>(
            dropdownColor: Theme.of(context).scaffoldBackgroundColor,
            underline: SizedBox(),
            padding: EdgeInsets.only(left: 8, right: 4),
            iconSize: 20,
            style: Theme.of(context).textTheme.bodyMedium,
            borderRadius: BorderRadius.circular(12),
            value: currentDuration,
            items: <DropdownMenuItem<Duration>>[
              DropdownMenuItem<Duration>(
                value: const Duration(minutes: 15),
                child: Text('15 min')
              ),
              DropdownMenuItem<Duration>(
                value: const Duration(minutes: 30),
                child: Text('30 min')
              ),
              DropdownMenuItem<Duration>(
                value: const Duration(minutes: 45),
                child: Text('45 min')
              ),
              DropdownMenuItem<Duration>(
                value: const Duration(hours: 1),
                child: Text('1 hour')
              ),
              DropdownMenuItem<Duration>(
                value: const Duration(hours: 2),
                child: Text('2 hours')
              ),
            ], 
            onChanged: (value) {
              if (value == null) value = currentDuration;
              setState(() {
                currentDuration = value!;
              });
              UserDB.setSetting(SettingOption.SlideActionPostponeDuration, value);
            }
          );
        }
      ),
    );
  }

  Widget _buildSlideToLeftActionsSetting(BuildContext context, ) {
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      SwipeAction action = UserDB.getSetting(SettingOption.HomeTileSlideAction_ToLeft);

      return ListTileTheme(
        data: Theme.of(context).listTileTheme,
        child: ListTile(
          title: Text(
            "Swipe to Left Actions",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          minVerticalPadding: 20,
          trailing: Text(
            action.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          onTap: () async {
            await showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 5,
              context: context,
              builder: (context) => SwipeToLeftActionSheet(),
            );
            setState(() {}); // Refresh the tile after modal is closed
          },
        ),
      );
    },
  );
}

Widget _buildSlideToRightActionsSetting(BuildContext context) {
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      SwipeAction action = UserDB.getSetting(SettingOption.HomeTileSlideAction_ToRight);

      return ListTileTheme(
        data: Theme.of(context).listTileTheme,
        child: ListTile(
          title: Text(
            "Swipe to Right Actions",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          minVerticalPadding: 20,
          trailing: Text(
            action.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          onTap: () async {
            await showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 5,
              context: context,
              builder: (context) => SwipeToRightActionSheet(),
            );
            setState(() {}); // Refresh the tile after modal is closed
          },
        ),
      );
    },
  );
}
}