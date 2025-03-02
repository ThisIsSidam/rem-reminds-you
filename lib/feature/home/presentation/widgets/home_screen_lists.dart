import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/data/models/no_rush_reminder/no_rush_reminder.dart';
import '../../../../core/data/models/reminder/reminder.dart';
import '../../../../core/enums/swipe_actions.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import 'action_pane_manager.dart';
import 'reminder_tile.dart';

class ListedReminderSection extends ConsumerWidget {
  const ListedReminderSection({
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
    final (SwipeAction, SwipeAction) actions = ref.watch(
      userSettingsProvider.select(
        (UserSettingsNotifier p) =>
            (p.homeTileSwipeActionRight, p.homeTileSwipeActionLeft),
      ),
    );

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
                Builder(
                  builder: (BuildContext context) {
                    final ActionPaneManager paneManager = ActionPaneManager(
                      reminder: remindersList[i],
                      remove: () {
                        remindersList.removeAt(i);
                      },
                      context: context,
                      ref: ref,
                    );
                    return Slidable(
                      key: ValueKey<int>(remindersList[i].id),
                      startActionPane: paneManager.getActionPane(actions.$1),
                      endActionPane: paneManager.getActionPane(actions.$2),
                      child: HomePageReminderEntryListTile(
                        reminder: remindersList[i],
                      ),
                    );
                  },
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

class ListedNoRushSection extends ConsumerWidget {
  const ListedNoRushSection({
    required this.label,
    required this.remindersList,
    super.key,
    this.hideIfEmpty = false,
  });
  final Widget label;
  final List<NoRushReminderModel> remindersList;
  final bool hideIfEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (hideIfEmpty && remindersList.isEmpty) {
      return const SizedBox.shrink();
    }
    final (SwipeAction, SwipeAction) actions = ref.watch(
      userSettingsProvider.select(
        (UserSettingsNotifier p) =>
            (p.homeTileSwipeActionRight, p.homeTileSwipeActionLeft),
      ),
    );

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
                Builder(
                  builder: (BuildContext context) {
                    final NoRushPaneManager paneManager = NoRushPaneManager(
                      reminder: remindersList[i],
                      remove: () {
                        remindersList.removeAt(i);
                      },
                      context: context,
                      ref: ref,
                    );
                    return Slidable(
                      key: ValueKey<int>(remindersList[i].id),
                      startActionPane: paneManager.getActionPane(actions.$1),
                      endActionPane: paneManager.getActionPane(actions.$2),
                      child: NoRushReminderListTile(
                        reminder: remindersList[i],
                      ),
                    );
                  },
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
