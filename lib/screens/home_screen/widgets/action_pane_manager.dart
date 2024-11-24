import 'package:Rem/modals/no_rush_reminders/no_rush_reminders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../consts/enums/swipe_actions.dart';
import '../../../modals/recurring_interval/recurring_interval.dart';
import '../../../modals/recurring_reminder/recurring_reminder.dart';
import '../../../modals/reminder_modal/reminder_modal.dart';
import '../../../provider/reminders_provider.dart';
import '../../../provider/settings_provider.dart';
import '../../../widgets/one_time_undo_button/one_time_undo_button.dart';
import '../../../widgets/snack_bar/custom_snack_bar.dart';

class ActionPaneManager {
  static ActionPane? getActionToLeft(
    WidgetRef ref,
    List<ReminderModal> remindersList,
    int index,
    BuildContext context,
  ) {
    final SwipeAction action =
        ref.read(userSettingsProvider).homeTileSwipeActionLeft;

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

  static ActionPane? getActionToRight(
    WidgetRef ref,
    List<ReminderModal> remindersList,
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
    ReminderModal reminder,
    WidgetRef ref,
  ) {
    return ActionPane(
        motion: const StretchMotion(),
        children: [_doneSlidableAction(context, reminder, ref)]);
  }

  static ActionPane _deleteActionPane(
    List<ReminderModal> remindersList,
    int index,
    BuildContext context,
    WidgetRef ref,
  ) {
    final ReminderModal reminder = remindersList[index];

    return ActionPane(
        motion: const StretchMotion(),
        dragDismissible: true,
        dismissible: DismissiblePane(onDismissed: () {
          remindersList.removeAt(index);
          _slideAndRemoveReminder(context, reminder, ref);
        }),
        children: [
          SlidableAction(
              backgroundColor: Colors.red,
              icon: Icons.delete_forever,
              onPressed: (context) {
                remindersList.removeAt(index);
                _slideAndRemoveReminder(context, reminder, ref);
              })
        ]);
  }

  static ActionPane _doneAndDeleteActionPane(
    BuildContext context,
    List<ReminderModal> remindersList,
    int index,
    WidgetRef ref,
  ) {
    final reminder = remindersList[index];

    return ActionPane(motion: const StretchMotion(), children: [
      if (reminder is! NoRushRemindersModal)
        SlidableAction(
          backgroundColor: Colors.red,
          icon: Icons.delete_forever,
          onPressed: (context) {
            remindersList.removeAt(index);
            _slideAndRemoveReminder(context, reminder, ref);
          },
        ),
      _doneSlidableAction(context, reminder, ref),
    ]);
  }

  static void _slideAndRemoveReminder(
    BuildContext context,
    ReminderModal reminder,
    WidgetRef ref,
  ) {
    // Store the provider reference before any potential disposal
    final remindersProviderValue = ref.read(remindersProvider);

    if (reminder is RecurringReminderModal &&
        reminder.recurringInterval != RecurringInterval.none) {
      showDialog(
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
              'This is a recurring reminder. Do you really want to delete it? You can also archive it.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actions: [
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
                  remindersProviderValue.moveToArchive(reminder.id);

                  final ValueKey snackBarKey =
                      ValueKey<String>('archived-${reminder.id}');
                  ScaffoldMessenger.of(context)
                      .showSnackBar(buildCustomSnackBar(
                          key: snackBarKey,
                          content: Row(
                            children: [
                              Text("'${reminder.title}' Archived."),
                              const Spacer(),
                              OneTimeUndoButton(
                                onPressed: () {
                                  remindersProviderValue
                                      .retrieveFromArchives(reminder.id);
                                },
                              )
                            ],
                          )));
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Archive',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton(
                onPressed: () {
                  remindersProviderValue.deleteReminder(reminder.id);

                  ScaffoldMessenger.of(context)
                      .showSnackBar(buildCustomSnackBar(
                          content: Row(
                    children: [
                      Text("'${reminder.title}' deleted"),
                      const Spacer(),
                      OneTimeUndoButton(
                        onPressed: () {
                          remindersProviderValue.saveReminder(reminder);
                        },
                      )
                    ],
                  )));
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

      ScaffoldMessenger.of(context).showSnackBar(buildCustomSnackBar(
          content: Row(
        children: [
          Text("'${reminder.title}' deleted"),
          const Spacer(),
          OneTimeUndoButton(
            onPressed: () {
              remindersProviderValue.saveReminder(reminder);
            },
          )
        ],
      )));
    }
  }

  // We should also fix the same issue in _postponeActionPane
  static ActionPane _postponeActionPane(
    BuildContext context,
    ReminderModal reminder,
    WidgetRef ref,
  ) {
    final Duration postponeDuration =
        ref.read(userSettingsProvider).defaultPostponeDuration;
    final remindersProviderValue = ref.read(remindersProvider);

    return ActionPane(motion: const StretchMotion(), children: [
      SlidableAction(
        icon: Icons.add,
        onPressed: (context) {
          reminder.dateTime = reminder.dateTime.add(postponeDuration);
          remindersProviderValue.saveReminder(reminder);

          final ValueKey snackBarKey =
              ValueKey<String>('postponed-${reminder.id}');
          ScaffoldMessenger.of(context).showSnackBar(buildCustomSnackBar(
              key: snackBarKey,
              content: Row(
                children: [
                  Text("'${reminder.title}' postponed."),
                  const Spacer(),
                  OneTimeUndoButton(
                    onPressed: () {
                      reminder.dateTime =
                          reminder.dateTime.subtract(postponeDuration);
                      remindersProviderValue.saveReminder(reminder);
                    },
                  )
                ],
              )));
        },
      )
    ]);
  }

  // Also fix _doneSlidableAction
  static Widget _doneSlidableAction(
    BuildContext context,
    ReminderModal reminder,
    WidgetRef ref,
  ) {
    final remindersProviderValue = ref.read(remindersProvider);

    return SlidableAction(
      backgroundColor: Colors.green,
      icon: Icons.check,
      onPressed: (context) {
        remindersProviderValue.markAsDone(reminder.id);

        if (reminder is! RecurringReminderModal ||
            reminder.recurringInterval == RecurringInterval.none) {
          final ValueKey snackBarKey =
              ValueKey<String>('archived-${reminder.id}');
          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(
              key: snackBarKey,
              content: Row(
                children: [
                  Text("'${reminder.title}' Archived."),
                  const Spacer(),
                  OneTimeUndoButton(
                    onPressed: () {
                      remindersProviderValue.retrieveFromArchives(reminder.id);
                    },
                  )
                ],
              ),
            ),
          );
        } else {
          final ValueKey snackBarKey = ValueKey<String>('moved-${reminder.id}');
          ScaffoldMessenger.of(context).showSnackBar(
            buildCustomSnackBar(
              key: snackBarKey,
              content: Row(
                children: [
                  Text("'${reminder.title}' moved to next occurrence."),
                  const Spacer(),
                  OneTimeUndoButton(
                    onPressed: () {
                      remindersProviderValue
                          .moveToPreviousReminderOccurrence(reminder.id);
                    },
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
