import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/enums/swipe_actions.dart';
import '../../../../../../core/extensions/context_ext.dart';
import '../../../providers/settings_provider.dart';
import '../../shared/dynamic_subtitle_setting_tile.dart';
import 'swipe_to_left_action_sheet.dart';
import 'swipe_to_right_action_sheet.dart';

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
            context.local.settingsGestures,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
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

  Widget _buildSlideToLeftActionsSetting(BuildContext context) {
    return DynamicSubtitleSettingTile<SwipeAction>(
      leading: Icons.swipe_left,
      title: context.local.settingsSwipeToLeftActions,
      selector: (UserSettingsNotifier p) => p.homeTileSwipeActionLeft,
      subtitleBuilder: (BuildContext context, SwipeAction? value) =>
          value?.localizedName(context) ?? '',
      onTap: (BuildContext context, WidgetRef ref, SwipeAction? value) async {
        await showModalBottomSheet<void>(
          isScrollControlled: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 5,
          context: context,
          builder: (BuildContext context) => const SwipeToLeftActionSheet(),
        );
      },
    );
  }

  Widget _buildSlideToRightActionsSetting(BuildContext context) {
    return DynamicSubtitleSettingTile<SwipeAction>(
      leading: Icons.swipe_right,
      title: context.local.settingsSwipeToRightActions,
      selector: (UserSettingsNotifier p) => p.homeTileSwipeActionRight,
      subtitleBuilder: (BuildContext context, SwipeAction? value) =>
          value?.localizedName(context) ?? '',
      onTap: (BuildContext context, WidgetRef ref, SwipeAction? value) async {
        await showModalBottomSheet<void>(
          isScrollControlled: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 5,
          context: context,
          builder: (BuildContext context) => const SwipeToRightActionSheet(),
        );
      },
    );
  }
}
