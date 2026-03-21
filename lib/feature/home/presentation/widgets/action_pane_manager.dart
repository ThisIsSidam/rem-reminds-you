import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../app/enums/swipe_actions.dart';
import '../../../../core/data/models/no_rush_reminder/no_rush_reminder.dart';
import '../../../../core/data/models/reminder/reminder.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../shared/widgets/snack_bar/custom_snack_bar.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/no_rush_provider.dart';
import '../providers/reminders_provider.dart';

class ActionPaneManager {
  const ActionPaneManager({
    required this.context,
    required this.ref,
    required this.reminder,
  });

  final BuildContext context;
  final WidgetRef ref;
  final ReminderModel reminder;

  ActionPane? getActionPane(SwipeAction action) {
    switch (action) {
      case SwipeAction.none:
        return null;
      case SwipeAction.done:
        return reminder.isRecurring ? _doneActionPane(ref) : null;
      case SwipeAction.delete:
        return _deleteActionPane(context, ref);
      case SwipeAction.postpone:
        return _postponeActionPane(ref);
      case SwipeAction.doneAndDelete:
        return _doneAndDeleteActionPane(context, ref);
    }
  }

  ActionPane _doneActionPane(WidgetRef ref) {
    return ActionPane(
      motion: const StretchMotion(),
      children: <Widget>[
        _doneSlidableAction(ref),
      ],
    );
  }

  ActionPane _deleteActionPane(BuildContext context, WidgetRef ref) {
    return ActionPane(
      motion: const StretchMotion(),
      dismissible: DismissiblePane(
        onDismissed: () => _slideAndRemoveReminder(context, ref),
      ),
      children: <Widget>[
        SlidableAction(
          backgroundColor: Colors.red,
          icon: Icons.delete_forever,
          onPressed: (BuildContext context) =>
              _slideAndRemoveReminder(context, ref),
        ),
      ],
    );
  }

  ActionPane _doneAndDeleteActionPane(BuildContext context, WidgetRef ref) {
    return ActionPane(
      motion: const StretchMotion(),
      children: <Widget>[
        SlidableAction(
          backgroundColor: Colors.red,
          icon: Icons.delete_forever,
          onPressed: (BuildContext context) =>
              _slideAndRemoveReminder(context, ref),
        ),
        if (reminder.isRecurring) _doneSlidableAction(ref),
      ],
    );
  }

  void _slideAndRemoveReminder(BuildContext context, WidgetRef ref) {
    // Store the provider reference before any potential disposal
    final RemindersNotifier remindersProviderValue = ref
        .read(remindersNotifierProvider.notifier)
      ..deleteReminder(reminder.id);
    AppUtils.showToast(
      msg: '${reminder.title} ${context.local.actionDeleted}',
      description: context.local.actionTapToUndo,
      onTap: () {
        remindersProviderValue.saveReminder(reminder);
      },
    );
  }

  ActionPane _postponeActionPane(WidgetRef ref) {
    final Duration postponeDuration =
        ref.read(userSettingsProvider).defaultPostponeDuration;
    final RemindersNotifier remindersProviderValue =
        ref.read(remindersNotifierProvider.notifier);

    return ActionPane(
      motion: const StretchMotion(),
      children: <Widget>[
        SlidableAction(
          icon: Icons.add,
          onPressed: (BuildContext context) {
            remindersProviderValue.saveReminder(
              reminder.copyWith(
                dateTime: reminder.getPostponeDt(postponeDuration),
              ),
            );

            AppUtils.showToast(
              msg: '${reminder.title} ${context.local.actionPostponed}',
              description: context.local.actionTapToUndo,
              onTap: () {
                remindersProviderValue.saveReminder(reminder);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _doneSlidableAction(WidgetRef ref) {
    final RemindersNotifier remindersProviderValue =
        ref.read(remindersNotifierProvider.notifier);

    return SlidableAction(
      backgroundColor: Colors.green,
      icon: Icons.check,
      onPressed: (BuildContext context) {
        remindersProviderValue.markAsDone(<int>[reminder.id]);
        final DateTime previous = reminder.dateTime;
        if (reminder.isNotRecurring) {
          return;
        } else {
          AppUtils.showToast(
            msg: '${reminder.title} ${context.local.actionMovedNextOccurrence}',
            description: context.local.actionTapToUndo,
            onTap: () {
              remindersProviderValue.moveToPreviousReminderOccurrence(
                reminder.id,
                previous,
              );
            },
          );
        }
      },
    );
  }
}

class NoRushPaneManager {
  const NoRushPaneManager({
    required this.context,
    required this.ref,
    required this.reminder,
  });

  final BuildContext context;
  final WidgetRef ref;
  final NoRushReminderModel reminder;

  ActionPane? getActionPane(SwipeAction action) {
    switch (action) {
      case SwipeAction.none:
        return null;
      case SwipeAction.done:
        return null;
      case SwipeAction.delete:
        return _deleteActionPane(context, ref);
      case SwipeAction.postpone:
        return _postponeActionPane(ref);
      case SwipeAction.doneAndDelete:
        return _deleteActionPane(context, ref);
    }
  }

  ActionPane _deleteActionPane(BuildContext context, WidgetRef ref) {
    return ActionPane(
      motion: const StretchMotion(),
      dismissible: DismissiblePane(
        onDismissed: () => _slideAndRemoveReminder(context, ref),
      ),
      children: <Widget>[
        SlidableAction(
          backgroundColor: Colors.red,
          icon: Icons.delete_forever,
          onPressed: (BuildContext context) =>
              _slideAndRemoveReminder(context, ref),
        ),
      ],
    );
  }

  void _slideAndRemoveReminder(BuildContext context, WidgetRef ref) {
    // Store the provider reference before any potential disposal
    final NoRushRemindersNotifier noRushNotifier = ref
        .read(noRushRemindersNotifierProvider.notifier)
      ..deleteReminder(reminder.id);
    AppUtils.showToast(
      msg: '${reminder.title} ${context.local.actionDeleted}',
      description: context.local.actionTapToUndo,
      onTap: () {
        noRushNotifier.saveReminder(reminder);
      },
    );
  }

  ActionPane _postponeActionPane(WidgetRef ref) {
    final NoRushRemindersNotifier noRushNotifier =
        ref.read(noRushRemindersNotifierProvider.notifier);

    return ActionPane(
      motion: const StretchMotion(),
      children: <Widget>[
        SlidableAction(
          icon: Icons.add,
          onPressed: (BuildContext context) {
            noRushNotifier.postponeReminder(reminder);
            AppUtils.showToast(
              msg: '${reminder.title} ${context.local.actionPostponed}',
              description: context.local.actionTapToUndo,
              onTap: () {
                noRushNotifier.saveReminder(reminder);
              },
            );
          },
        ),
      ],
    );
  }
}
