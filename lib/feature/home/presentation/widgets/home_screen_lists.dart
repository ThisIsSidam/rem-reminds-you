import 'package:Rem/feature/home/presentation/widgets/list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/models/basic_reminder_model.dart';
import 'action_pane_manager.dart';

class HomeScreenReminderListSection extends ConsumerWidget {
  final Widget label;
  final List<BasicReminderModel> remindersList;
  final bool hideIfEmpty;

  const HomeScreenReminderListSection({
    super.key,
    required this.label,
    required this.remindersList,
    this.hideIfEmpty = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (hideIfEmpty && remindersList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: label,
          ),
          SizedBox(height: 4),
          Column(
            children: [
              for (int i = 0; i < remindersList.length; i++) ...<Widget>[
                SizedBox(height: 4),
                Slidable(
                  key: ValueKey(remindersList[i].id),
                  startActionPane: ActionPaneManager.getActionToRight(
                    ref,
                    remindersList,
                    i,
                    context,
                  ),
                  endActionPane: ActionPaneManager.getActionToLeft(
                      ref, remindersList, i, context),
                  child: HomePageReminderEntryListTile(
                    reminder: remindersList[i],
                  ),
                ),
                SizedBox(height: 4),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
