import 'package:flutter/material.dart';

import '../../../../../../app/enums/swipe_actions.dart';

class SwipeActionPicker extends StatelessWidget {
  const SwipeActionPicker({
    required this.selectedAction,
    required this.onSelect,
    super.key,
  });

  final SwipeAction selectedAction;
  final ValueChanged<SwipeAction> onSelect;

  @override
  Widget build(BuildContext context) {
    const actions = SwipeAction.values;
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildExpandedButton(context, actions[0]),
              const SizedBox(width: 2),
              _buildExpandedButton(context, actions[1]),
              const SizedBox(width: 2),
              _buildExpandedButton(context, actions[2]),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              _buildExpandedButton(context, actions[3]),
              const SizedBox(width: 2),
              _buildExpandedButton(context, actions[4]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedButton(BuildContext context, SwipeAction action) {
    return Expanded(
      child: SizedBox(
        height: 60, // Fixed height for consistency
        child: _buildButton(context, action),
      ),
    );
  }

  Widget _buildButton(BuildContext context, SwipeAction action) {
    final isSelected = action == selectedAction;
    return ElevatedButton(
      onPressed: () => onSelect(action),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(4),
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.secondaryContainer,
        shape: const BeveledRectangleBorder(),
      ),
      child: Text(
        action.localizedName(context),
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSecondaryContainer,
            ),
      ),
    );
  }
}
