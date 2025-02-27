import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/data/models/no_rush_reminder/no_rush_reminder.dart';
import '../../../../core/data/models/recurring_interval/recurring_interval.dart';
import '../../../../core/data/models/reminder/recurring_reminder.dart';
import '../../../../core/data/models/reminder_model/reminder_model.dart';
import '../../../../core/enums/swipe_actions.dart';
import '../../../../shared/widgets/snack_bar/custom_snack_bar.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/reminders_provider.dart';

class ActionPaneManager {
  static ActionPane? getActionToLeft(
    WidgetRef ref,
    List<ReminderModel> remindersList,
    int index,
    BuildContext context,
  ) {
    final SwipeAction action =
        ref.read(userSettingsProvider).homeTileSwipeActionLeft;
    final ReminderModel reminder = remindersList[index];

    switch (action) {
      case SwipeAction.none:
        return null;
      case SwipeAction.done:
        return _doneActionPane(
          context,
          reminder,
          ref,
        );
      case SwipeAction.delete:
        return _deleteActionPane(
          remindersList,
          index,
          context,
          ref,
        );
      case SwipeAction.postpone:
        return reminder is NoRushReminderModel
            ? null
            : _postponeActionPane(
                context,
                reminder,
                ref,
              );
      case SwipeAction.doneAndDelete:
        return _doneAndDeleteActionPane(context, remindersList, index, ref);
    }
  }

  static ActionPane? getActionToRight(
    WidgetRef ref,
    List<ReminderModel> remindersList,
    int index,
    BuildContext context,
  ) {
    final SwipeAction action =
        ref.read(userSettingsProvider).homeTileSwipeActionRight;

    switch (action) {
      case SwipeAction.none:
        return null;
      case SwipeAction.done:
        return _doneActionPane(
          context,
          remindersList[index],
          ref,
        );
      case SwipeAction.delete:
        return _deleteActionPane(
          remindersList,
          index,
          context,
          ref,
        );
      case SwipeAction.postpone:
        return _postponeActionPane(
          context,
          remindersList[index],
          ref,
        );
      case SwipeAction.doneAndDelete:
        return _doneAndDeleteActionPane(context, remindersList, index, ref);
    }
  }

  static ActionPane _doneActionPane(
    BuildContext context,
    ReminderModel reminder,
    WidgetRef ref,
  ) {
    return ActionPane(
      motion: const StretchMotion(),
      children: <Widget>[_doneSlidableAction(context, reminder, ref)],
    );
  }

  static ActionPane _deleteActionPane(
    List<ReminderModel> remindersList,
    int index,
    BuildContext context,
    WidgetRef ref,
  ) {
    final ReminderModel reminder = remindersList[index];

    return ActionPane(
      motion: const StretchMotion(),
      dismissible: DismissiblePane(
        onDismissed: () {
          remindersList.removeAt(index);
          _slideAndRemoveReminder(context, reminder, ref);
        },
      ),
      children: <Widget>[
        SlidableAction(
          backgroundColor: Colors.red,
          icon: Icons.delete_forever,
          onPressed: (BuildContext context) {
            remindersList.removeAt(index);
            _slideAndRemoveReminder(context, reminder, ref);
          },
        ),
      ],
    );
  }

  static ActionPane _doneAndDeleteActionPane(
    BuildContext context,
    List<ReminderModel> remindersList,
    int index,
    WidgetRef ref,
  ) {
    final ReminderModel reminder = remindersList[index];

    return ActionPane(
      motion: const StretchMotion(),
      children: <Widget>[
        SlidableAction(
          backgroundColor: Colors.red,
          icon: Icons.delete_forever,
          onPressed: (BuildContext context) {
            remindersList.removeAt(index);
            _slideAndRemoveReminder(context, reminder, ref);
          },
        ),
        _doneSlidableAction(context, reminder, ref),
      ],
    );
  }

  static void _slideAndRemoveReminder(
    BuildContext context,
    ReminderModel reminder,
    WidgetRef ref,
  ) {
    // Store the provider reference before any potential disposal
    final RemindersNotifier remindersProviderValue =
        ref.read(remindersProvider);

    if (reminder is RecurringReminderModel &&
        reminder.recurringInterval != RecurringInterval.isNone) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 5,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              'Recurring Reminder',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            content: Text(
              // ignore: lines_longer_than_80_chars
              'This is a recurring reminder. Do you really want to delete it? You can also archive it.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton(
                onPressed: () {
                  remindersProviderValue.deleteReminder(reminder.id);
                  AppUtils.showToast(
                    msg: "'${reminder.title}' deleted",
                    description: 'Tap to undo',
                    onTap: () {
                      remindersProviderValue.saveReminder(reminder);
                    },
                  );

                  Navigator.of(context).pop();
                },
                child: Text(
                  'Delete',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          );
        },
      );
    } else {
      remindersProviderValue.deleteReminder(reminder.id);
      AppUtils.showToast(
        msg: "'${reminder.title}' deleted",
        description: 'Tap to undo',
        onTap: () {
          remindersProviderValue.saveReminder(reminder);
        },
      );
    }
  }

  // We should also fix the same issue in _postponeActionPane
  static ActionPane _postponeActionPane(
    BuildContext context,
    ReminderModel reminder,
    WidgetRef ref,
  ) {
    final Duration postponeDuration =
        ref.read(userSettingsProvider).defaultPostponeDuration;
    final RemindersNotifier remindersProviderValue =
        ref.read(remindersProvider);

    return ActionPane(
      motion: const StretchMotion(),
      children: <Widget>[
        SlidableAction(
          icon: Icons.add,
          onPressed: (BuildContext context) {
            reminder.dateTime = reminder.dateTime.add(postponeDuration);
            remindersProviderValue.saveReminder(reminder);

            AppUtils.showToast(
              msg: "'${reminder.title}' postponed.",
              description: 'Tap to undo',
              onTap: () {
                reminder.dateTime =
                    reminder.dateTime.subtract(postponeDuration);
                remindersProviderValue.saveReminder(reminder);
              },
            );
          },
        ),
      ],
    );
  }

  // Also fix _doneSlidableAction
  static Widget _doneSlidableAction(
    BuildContext context,
    ReminderModel reminder,
    WidgetRef ref,
  ) {
    final RemindersNotifier remindersProviderValue =
        ref.read(remindersProvider);

    return SlidableAction(
      backgroundColor: Colors.green,
      icon: Icons.check,
      onPressed: (BuildContext context) {
        remindersProviderValue.markAsDone(<int>[reminder.id]);

        if (reminder is! RecurringReminderModel ||
            reminder.recurringInterval == RecurringInterval.isNone) {
          AppUtils.showToast(
            msg: "'${reminder.title}' Archived.",
            description: 'Tap to undo',
            onTap: () {
              remindersProviderValue.retrieveFromArchives(reminder.id);
            },
          );
        } else {
          AppUtils.showToast(
            msg: "'${reminder.title}' moved to next occurrence.",
            description: 'Tap to undo',
            onTap: () {
              remindersProviderValue
                  .moveToPreviousReminderOccurrence(reminder.id);
            },
          );
        }
      },
    );
  }
}
