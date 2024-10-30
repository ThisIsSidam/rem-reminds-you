import 'package:Rem/consts/enums/swipe_actions.dart';
import 'package:Rem/provider/settings_provider.dart';
import 'package:Rem/provider/text_scale_provider.dart';
import 'package:Rem/screens/settings_screen/sections/user_preferences_section/swipe_to_left_action_sheet.dart';
import 'package:Rem/screens/settings_screen/sections/user_preferences_section/swipe_to_right_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPreferenceSection extends StatelessWidget {
  const UserPreferenceSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.supervised_user_circle_outlined,
              color: Colors.transparent),
          title: Text(
            "User Preferences",
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        SizedBox(height: 5),
        Column(
          children: [
            SizedBox(height: 10),
            _buildSlideToLeftActionsSetting(context),
            SizedBox(
              height: 10,
            ),
            _buildSlideToRightActionsSetting(context),
            SizedBox(height: 10),
            _buildTextScaleSetting(context),
            SizedBox(height: 10),
            _buildQuickPostponeDurationSetting(context),
            SizedBox(
              height: 20,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTextScaleSetting(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.format_size),
      title: Text('Text Scale', style: Theme.of(context).textTheme.titleSmall),
      subtitle: Consumer(builder: (context, ref, child) {
        final textScale = ref.watch(textScaleProvider).textScale;
        return Row(
          children: [
            Expanded(
              child: Slider(
                value: textScale,
                min: 0.8,
                max: 1.4,
                label: '${textScale}x',
                divisions: 6,
                onChanged: (val) {
                  ref.read(textScaleProvider).textScale = val;
                },
                inactiveColor: Theme.of(context).colorScheme.secondary,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text('${textScale.toStringAsPrecision(2)}x',
                style: Theme.of(context).textTheme.bodyMedium)
          ],
        );
      }),
    );
  }

  Widget _buildQuickPostponeDurationSetting(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.more_time),
      title: Text('Postpone Duration',
          style: Theme.of(context).textTheme.titleSmall),
      trailing: Consumer(builder: (context, ref, child) {
        Duration currentDuration =
            ref.watch(userSettingsProvider).defaultPostponeDuration;
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
                  value: const Duration(minutes: 15), child: Text('15 min')),
              DropdownMenuItem<Duration>(
                  value: const Duration(minutes: 30), child: Text('30 min')),
              DropdownMenuItem<Duration>(
                  value: const Duration(minutes: 45), child: Text('45 min')),
              DropdownMenuItem<Duration>(
                  value: const Duration(hours: 1), child: Text('1 hour')),
              DropdownMenuItem<Duration>(
                  value: const Duration(hours: 2), child: Text('2 hours')),
            ],
            onChanged: (value) {
              if (value == null) value = currentDuration;
              ref.read(userSettingsProvider).defaultPostponeDuration = value;
            });
      }),
    );
  }

  Widget _buildSlideToLeftActionsSetting(
    BuildContext context,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        SwipeAction action =
            ref.watch(userSettingsProvider).homeTileSwipeActionLeft;

        return ListTile(
          leading: Icon(Icons.swipe_left),
          title: Text(
            "Swipe to Left Actions",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          minVerticalPadding: 20,
          subtitle: Text(
            action.toString(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () async {
            await showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 5,
              context: context,
              builder: (context) => SwipeToLeftActionSheet(),
            );
          },
        );
      },
    );
  }

  Widget _buildSlideToRightActionsSetting(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        SwipeAction action =
            ref.watch(userSettingsProvider).homeTileSwipeActionRight;

        return ListTile(
          leading: Icon(Icons.swipe_right),
          title: Text(
            "Swipe to Right Actions",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          minVerticalPadding: 20,
          subtitle: Text(
            action.toString(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () async {
            await showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 5,
              context: context,
              builder: (context) => SwipeToRightActionSheet(),
            );
          },
        );
      },
    );
  }
}
