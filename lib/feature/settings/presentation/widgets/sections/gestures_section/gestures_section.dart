import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/enums/swipe_actions.dart';
import '../../../providers/settings_provider.dart';
import '../user_preferences_section/swipe_to_left_action_sheet.dart';
import '../user_preferences_section/swipe_to_right_action_sheet.dart';

class GesturesSection extends ConsumerWidget {
  const GesturesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.near_me, color: Colors.transparent),
          title: Text(
            "Gestures",
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        SizedBox(height: 5),
        Column(
          children: [
            _buildSlideToLeftActionsSetting(context),
            _buildSlideToRightActionsSetting(context),
          ],
        )
      ],
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
