import 'package:Rem/core/enums/swipe_actions.dart';
import 'package:Rem/feature/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SwipeToRightActionSheet extends ConsumerWidget {
  SwipeToRightActionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Swipe to Left Actions",
                style: Theme.of(context).textTheme.titleMedium),
            Divider(),
            const SizedBox(height: 30),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 3; i++)
                    Icon(
                      Icons.chevron_right,
                    ),
                  const SizedBox(width: 20),
                  Text('Swipe Right',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          )),
                  const SizedBox(width: 20),
                  for (int i = 0; i < 3; i++)
                    Icon(
                      Icons.chevron_right,
                    ),
                ],
              ),
              tileColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
            ),
            const SizedBox(height: 40),
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: GridView.count(
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                crossAxisCount: 3,
                shrinkWrap: true,
                childAspectRatio: 1.5,
                children: [
                  for (final SwipeAction action in SwipeAction.values)
                    _buildButton(action, context, ref)
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildButton(SwipeAction action, BuildContext context, WidgetRef ref) {
    SwipeAction selectedAction =
        ref.watch(userSettingsProvider).homeTileSwipeActionRight;

    return ElevatedButton(
      onPressed: () {
        ref.read(userSettingsProvider).homeTileSwipeActionRight = action;
      },
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(4),
          backgroundColor: action == selectedAction
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.secondaryContainer,
          shape: BeveledRectangleBorder()),
      child: Text(
        action.toString(),
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: action == selectedAction
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSecondaryContainer),
      ),
    );
  }
}
