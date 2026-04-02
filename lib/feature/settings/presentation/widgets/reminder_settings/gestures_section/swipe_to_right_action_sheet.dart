import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/enums/swipe_actions.dart';
import '../../../../../../core/extensions/context_ext.dart';
import '../../../../../../shared/widgets/sheet_handle.dart';
import 'swipe_action_picker.dart';

Future<SwipeAction?> showSwipeToRightActionSheet(
  BuildContext context, {
  required SwipeAction initialAction,
}) {
  return showModalBottomSheet<SwipeAction>(
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    elevation: 5,
    context: context,
    builder: (BuildContext context) =>
        SwipeToRightActionSheet(initialAction: initialAction),
  );
}

class SwipeToRightActionSheet extends ConsumerStatefulWidget {
  const SwipeToRightActionSheet({required this.initialAction, super.key});

  final SwipeAction initialAction;

  @override
  ConsumerState<SwipeToRightActionSheet> createState() =>
      _SwipeToRightActionSheetState();
}

class _SwipeToRightActionSheetState
    extends ConsumerState<SwipeToRightActionSheet> {
  late final _selectedActionNotifier = ValueNotifier(widget.initialAction);

  @override
  void dispose() {
    _selectedActionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10 + context.bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SheetHandle(),
          const SizedBox(height: 16),
          Text(
            context.local.settingsSwipeToRightActions,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (int i = 0; i < 3; i++) const Icon(Icons.chevron_right),
                const SizedBox(width: 20),
                Text(
                  context.local.settingsSwipeRight,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 20),
                for (int i = 0; i < 3; i++) const Icon(Icons.chevron_right),
              ],
            ),
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<SwipeAction>(
            valueListenable: _selectedActionNotifier,
            builder: (context, selectedAction, child) {
              return SwipeActionPicker(
                selectedAction: selectedAction,
                onSelect: (newAction) {
                  _selectedActionNotifier.value = newAction;
                  Navigator.pop(context, newAction);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
