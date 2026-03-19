import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/data/models/no_rush_reminder/no_rush_reminder.dart';
import '../../../../core/data/models/reminder/reminder.dart';
import '../../../../core/data/models/reminder_base/reminder_base.dart';
import '../../../../core/enums/swipe_actions.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../reminder_sheet/presentation/sheet_helper.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/model/dragged_reminder.dart';
import '../providers/no_rush_provider.dart';
import '../providers/reminder_dragging_provider.dart';
import '../providers/reminders_provider.dart';
import '../screens/home_screen.dart';
import 'action_pane_manager.dart';
import 'reminder_drag_zone.dart';
import 'reminder_tile.dart';

/// [ListedReminderSection] and [ListedNoRushSection] are identical
/// But keep separate and synced

class ListedReminderSection extends ConsumerWidget {
  const ListedReminderSection({
    required this.section,
    this.onTapTitle,
    this.hideIfEmpty = false,
    super.key,
  });

  /// The Homescreen section this widget belongs to.
  final HomeScreenSection section;

  /// Callback to run on tap of section title.
  final VoidCallback? onTapTitle;

  /// Whether to hide this section if [remindersList] is empty.
  final bool hideIfEmpty;

  void _clearDrag(WidgetRef ref) =>
      ref.read(reminderDraggingProvider.notifier).state = null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ReminderModel> reminders =
        ref.watch(remindersNotifierProvider)[section] ?? <ReminderModel>[];
    if (hideIfEmpty && reminders.isEmpty) {
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
          ReminderSectionTitle(section: section, onTap: onTapTitle),
          const SizedBox(height: 4),
          ReminderDragZone(
            homescreenSection: section,
            onDroppedAccepted: (ReminderBase reminder) => ref
                .read(remindersNotifierProvider.notifier)
                .moveReminder(reminder, section),
            child: Column(
              children: <Widget>[
                for (int i = 0; i < reminders.length; i++) ...<Widget>[
                  const SizedBox(height: 4),
                  Builder(
                    builder: (BuildContext context) {
                      final ReminderModel reminder = reminders[i];
                      final ActionPaneManager paneManager = ActionPaneManager(
                        reminder: reminder,
                        remove: () {
                          reminders.removeAt(i);
                        },
                        context: context,
                        ref: ref,
                      );
                      return Slidable(
                        key: ValueKey<int>(reminder.id),
                        startActionPane: paneManager.getActionPane(actions.$1),
                        endActionPane: paneManager.getActionPane(actions.$2),
                        child: LongPressDraggable<ReminderBase>(
                          data: reminder,
                          onDragStarted: () => ref
                              .read(reminderDraggingProvider.notifier)
                              .state = DraggedReminder(
                            reminder: reminder,
                            section: section,
                          ),
                          onDragEnd: (_) => _clearDrag(ref),
                          onDraggableCanceled: (_, __) => _clearDrag(ref),
                          onDragCompleted: () => _clearDrag(ref),
                          feedback: Material(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: min(MediaQuery.widthOf(context) - 40, 360),
                              child: HomePageReminderEntryListTile(
                                reminder: reminder,
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: HomePageReminderEntryListTile(
                              reminder: reminder,
                            ),
                          ),
                          child: HomePageReminderEntryListTile(
                            reminder: reminder,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// [HomeScreenSection] for [NoRushReminderModel].
class ListedNoRushSection extends ConsumerWidget {
  const ListedNoRushSection({super.key});

  HomeScreenSection get _section => HomeScreenSection.noRush;

  void _clearDrag(WidgetRef ref) =>
      ref.read(reminderDraggingProvider.notifier).state = null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<NoRushReminderModel> remindersList =
        ref.watch(noRushRemindersNotifierProvider);
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
          ReminderSectionTitle(
            section: _section,
            onTap: () => SheetHelper().openReminderSheet(
              context,
              isNoRush: true,
            ),
          ),
          const SizedBox(height: 4),
          ReminderDragZone(
            homescreenSection: _section,
            onDroppedAccepted: (ReminderBase reminder) {
              ref
                  .read(noRushRemindersNotifierProvider.notifier)
                  .moveReminder(reminder);
            },
            child: Column(
              children: <Widget>[
                for (int i = 0; i < remindersList.length; i++) ...<Widget>[
                  const SizedBox(height: 4),
                  Builder(
                    builder: (BuildContext context) {
                      final NoRushReminderModel reminder = remindersList[i];
                      final NoRushPaneManager paneManager = NoRushPaneManager(
                        reminder: reminder,
                        remove: () {
                          remindersList.removeAt(i);
                        },
                        context: context,
                        ref: ref,
                      );
                      return Slidable(
                        key: ValueKey<int>(reminder.id),
                        startActionPane: paneManager.getActionPane(actions.$1),
                        endActionPane: paneManager.getActionPane(actions.$2),
                        child: LongPressDraggable<NoRushReminderModel>(
                          data: reminder,
                          onDragStarted: () => ref
                              .read(reminderDraggingProvider.notifier)
                              .state = DraggedReminder(
                            reminder: reminder,
                            section: _section,
                          ),
                          onDragEnd: (_) => _clearDrag(ref),
                          onDraggableCanceled: (_, __) => _clearDrag(ref),
                          onDragCompleted: () => _clearDrag(ref),
                          feedback: Material(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: min(MediaQuery.widthOf(context) - 40, 360),
                              child: NoRushReminderListTile(
                                reminder: reminder,
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: NoRushReminderListTile(
                              reminder: reminder,
                            ),
                          ),
                          child: NoRushReminderListTile(
                            reminder: reminder,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderSectionTitle extends StatelessWidget {
  const ReminderSectionTitle({required this.section, this.onTap, super.key});

  final HomeScreenSection section;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            section.title,
            style: context.texts.titleMedium!.copyWith(
              color: section.getColor(context),
            ),
          ),
        ),
      ),
    );
  }
}
