import 'package:Rem/consts/enums/swipe_actions.dart';
import 'package:Rem/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SwipeToLeftActionSheet extends ConsumerWidget {
  SwipeToLeftActionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        height: 350,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            Text("Swipe to Left Actions",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 20),
                  Text('Swipe Left',
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(width: 20),
                  Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                for (final SwipeAction action in SwipeAction.values)
                  _buildOptionTile(action, context, ref)
              ],
            )
          ],
        ));
  }

  Widget _buildOptionTile(
      SwipeAction action, BuildContext context, WidgetRef ref) {
    SwipeAction selectedAction =
        ref.watch(userSettingsProvider).homeTileSwipeActionLeft;

    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
      child: GestureDetector(
        onTap: () {
          ref.read(userSettingsProvider).homeTileSwipeActionLeft = action;
        },
        child: Row(
          children: [
            Icon(Icons.check,
                color: action == selectedAction
                    ? Colors.white
                    : Colors.transparent),
            const SizedBox(width: 20),
            Text(action.toString(),
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
