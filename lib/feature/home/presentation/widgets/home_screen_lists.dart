import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/enums/swipe_actions.dart';
import '../../../../core/data/models/no_rush_reminder/no_rush_reminder.dart';
import '../../../../core/data/models/reminder/reminder.dart';
import '../../../../core/data/models/reminder_base/reminder_base.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../reminder_sheet/presentation/sheet_helper.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/no_rush_provider.dart';
import '../providers/reminders_provider.dart';
import '../screens/home_screen.dart';
import 'no_rush_reminder_tile.dart';
import 'normal_reminder_tile.dart';
import 'reminder_drag_zone.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ReminderModel> reminders =
        ref.watch(remindersNotifierProvider)[section] ?? <ReminderModel>[];
    if (hideIfEmpty && reminders.isEmpty) {
      return const SizedBox.shrink();
    }
    final SwipeActionPair actions = ref.watch(
      userSettingsProvider.select(
        (UserSettingsNotifier p) => (
          start: p.homeTileSwipeActionRight,
          end: p.homeTileSwipeActionLeft,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ReminderSectionTitle(section: section, onTap: onTapTitle),
          const SizedBox(height: 4),
          ReminderDragZone(
            homescreenSection: section,
            onDroppedAccepted: (ReminderBase reminder) => ref
                .read(remindersNotifierProvider.notifier)
                .moveReminder(reminder, section),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, int i) => NormalReminderTile(
                reminder: reminders[i],
                actions: actions,
                section: section,
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: reminders.length,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<NoRushReminderModel> reminders =
        ref.watch(noRushRemindersNotifierProvider);
    final SwipeActionPair actions = ref.watch(
      userSettingsProvider.select(
        (UserSettingsNotifier p) => (
          start: p.homeTileSwipeActionRight,
          end: p.homeTileSwipeActionLeft,
        ),
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
            onDroppedAccepted: (ReminderBase reminder) => ref
                .read(noRushRemindersNotifierProvider.notifier)
                .moveReminder(reminder),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, int i) => NoRushReminderTile(
                reminder: reminders[i],
                actions: actions,
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: reminders.length,
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
            section.localizedTitle(context),
            style: context.texts.titleMedium!.copyWith(
              color: section.getColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
