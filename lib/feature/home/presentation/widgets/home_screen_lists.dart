import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/models/reminder_model/reminder_model.dart';
import 'action_pane_manager.dart';
import 'reminder_tile.dart';

class HomeScreenReminderListSection extends ConsumerWidget {
  const HomeScreenReminderListSection({
    required this.label,
    required this.remindersList,
    super.key,
    this.hideIfEmpty = false,
  });
  final Widget label;
  final List<ReminderModel> remindersList;
  final bool hideIfEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (hideIfEmpty && remindersList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: label,
          ),
          const SizedBox(height: 4),
          Column(
            children: <Widget>[
              for (int i = 0; i < remindersList.length; i++) ...<Widget>[
                const SizedBox(height: 4),
                Slidable(
                  key: ValueKey<int>(remindersList[i].id),
                  startActionPane: ActionPaneManager.getActionToRight(
                    ref,
                    remindersList,
                    i,
                    context,
                  ),
                  endActionPane: ActionPaneManager.getActionToLeft(
                    ref,
                    remindersList,
                    i,
                    context,
                  ),
                  child: HomePageReminderEntryListTile(
                    reminder: remindersList[i],
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
