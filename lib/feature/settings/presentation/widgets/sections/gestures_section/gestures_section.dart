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
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.near_me, color: Colors.transparent),
          title: Text(
            'Gestures',
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        const SizedBox(height: 5),
        Column(
          children: <Widget>[
            _buildSlideToLeftActionsSetting(context),
            _buildSlideToRightActionsSetting(context),
          ],
        ),
      ],
    );
  }

  Widget _buildSlideToLeftActionsSetting(
    BuildContext context,
  ) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final SwipeAction action =
            ref.watch(userSettingsProvider).homeTileSwipeActionLeft;

        return ListTile(
          leading: const Icon(Icons.swipe_left),
          title: Text(
            'Swipe to Left Actions',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          minVerticalPadding: 20,
          subtitle: Text(
            action.toString(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () async {
            await showModalBottomSheet<void>(
              isScrollControlled: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 5,
              context: context,
              builder: (BuildContext context) => const SwipeToLeftActionSheet(),
            );
          },
        );
      },
    );
  }

  Widget _buildSlideToRightActionsSetting(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final SwipeAction action =
            ref.watch(userSettingsProvider).homeTileSwipeActionRight;

        return ListTile(
          leading: const Icon(Icons.swipe_right),
          title: Text(
            'Swipe to Right Actions',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          minVerticalPadding: 20,
          subtitle: Text(
            action.toString(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () async {
            await showModalBottomSheet<void>(
              isScrollControlled: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 5,
              context: context,
              builder: (BuildContext context) =>
                  const SwipeToRightActionSheet(),
            );
          },
        );
      },
    );
  }
}
