import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../app/enums/swipe_actions.dart';
import '../../../../core/data/models/no_rush_reminder/no_rush_reminder.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../reminder_sheet/presentation/sheet_helper.dart';
import '../../domain/model/dragged_reminder.dart';
import '../providers/reminder_dragging_provider.dart';
import '../screens/home_screen.dart';
import 'action_pane_manager.dart';

class NoRushReminderTile extends ConsumerWidget {
  const NoRushReminderTile({
    required this.reminder,
    required this.actions,
    super.key,
  });
  final NoRushReminderModel reminder;
  final SwipeActionPair actions;

  void _clearDrag(WidgetRef ref) =>
      ref.read(reminderDraggingProvider.notifier).state = null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget tile = _buildTile(context);
    final NoRushPaneManager paneManager = NoRushPaneManager(
      reminder: reminder,
      context: context,
      ref: ref,
    );
    return Slidable(
      key: ValueKey<int>(reminder.id),
      startActionPane: paneManager.getActionPane(actions.start),
      endActionPane: paneManager.getActionPane(actions.end),
      child: LongPressDraggable<NoRushReminderModel>(
        data: reminder,
        onDragStarted: () =>
            ref.read(reminderDraggingProvider.notifier).state = DraggedReminder(
          reminder: reminder,
          section: HomeScreenSection.noRush,
        ),
        onDragEnd: (_) => _clearDrag(ref),
        onDraggableCanceled: (_, __) => _clearDrag(ref),
        onDragCompleted: () => _clearDrag(ref),
        feedback: Material(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: min(MediaQuery.widthOf(context) - 40, 360),
            child: tile,
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: tile,
        ),
        child: tile,
      ),
    );
  }

  Widget _buildTile(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        SheetHelper().openReminderSheet(
          context,
          reminder: reminder,
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.inversePrimary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.inversePrimary.withValues(alpha: 0.25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: SizedBox(
            width: double.maxFinite,
            child: Text(
              reminder.title,
              style: context.texts.titleMedium,
              softWrap: true,
            ),
          ),
        ),
      ),
    );
  }
}
