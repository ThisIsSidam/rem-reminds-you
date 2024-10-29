import 'package:Rem/consts/consts.dart';
import 'package:Rem/consts/enums/swipe_actions.dart';
import 'package:Rem/provider/reminders_provider.dart';
import 'package:Rem/provider/settings_provider.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/home_screen/widgets/list_tile.dart';
import 'package:Rem/widgets/one_time_undo_button/one_time_undo_button.dart';
import 'package:Rem/widgets/snack_bar/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomeScreenReminderListSection extends ConsumerWidget {
  final Widget? label;
  final List<Reminder> remindersList;

  const HomeScreenReminderListSection({
    super.key,
    this.label,
    required this.remindersList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (remindersList.isEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            SizedBox(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: label,
            )),
          SizedBox(
            height: remindersList.length * (60 + 5), // Tile height + separators
            child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: remindersList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 4.0),
                itemBuilder: (context, index) {
                  final reminder = remindersList[index];

                  return Slidable(
                      key: ValueKey(reminder.id),
                      startActionPane: ActionPaneManager.getActionToRight(
                        ref,
                        remindersList,
                        index,
                        context,
                      ),
                      endActionPane: ActionPaneManager.getActionToLeft(
                          ref, remindersList, index, context),
                      child: HomePageReminderEntryListTile(reminder: reminder));
                }),
          ),
        ],
      ),
    );
  }
}

class ActionPaneManager {
  static ActionPane? getActionToLeft(
    WidgetRef ref,
    List<Reminder> remindersList,
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
    List<Reminder> remindersList,
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
    Reminder reminder,
    WidgetRef ref,
  ) {
    return ActionPane(
        motion: const StretchMotion(),
        children: [_doneSlidableAction(context, reminder, ref)]);
  }

  static ActionPane _deleteActionPane(
    List<Reminder> remindersList,
    int index,
    BuildContext context,
    WidgetRef ref,
  ) {
    final Reminder reminder = remindersList[index];

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
    List<Reminder> remindersList,
    int index,
    WidgetRef ref,
  ) {
    final reminder = remindersList[index];

    return ActionPane(motion: const StretchMotion(), children: [
      _doneSlidableAction(context, reminder, ref),
      SlidableAction(
          backgroundColor: Colors.red,
          icon: Icons.delete_forever,
          onPressed: (context) {
            remindersList.removeAt(index);
            _slideAndRemoveReminder(context, reminder, ref);
          })
    ]);
  }

  static void _slideAndRemoveReminder(
    BuildContext context,
    Reminder reminder,
    WidgetRef ref,
  ) {
    // Store the provider reference before any potential disposal
    final remindersProviderValue = ref.read(remindersProvider);

    if (reminder.recurringInterval != RecurringInterval.none) {
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
                  remindersProviderValue.moveToArchive(reminder.id!);

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
                                  // remindersProviderValue.retrieveFromArchives(reminder);
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
                  remindersProviderValue.deleteReminder(reminder.id!);

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
      remindersProviderValue.deleteReminder(reminder.id!);

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
    Reminder reminder,
    WidgetRef ref,
  ) {
    final Duration postponeDuration =
        ref.read(userSettingsProvider).defaultPostponeDuration;
    final remindersProviderValue = ref.read(remindersProvider);

    return ActionPane(motion: const StretchMotion(), children: [
      SlidableAction(
        icon: Icons.add,
        onPressed: (context) {
          reminder.dateAndTime = reminder.dateAndTime.add(postponeDuration);
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
                      reminder.dateAndTime =
                          reminder.dateAndTime.subtract(postponeDuration);
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
    Reminder reminder,
    WidgetRef ref,
  ) {
    final remindersProviderValue = ref.read(remindersProvider);

    return SlidableAction(
      backgroundColor: Colors.green,
      icon: Icons.check,
      onPressed: (context) {
        remindersProviderValue.markAsDone(reminder.id ?? reminderNullID);

        if (reminder.recurringInterval == RecurringInterval.none) {
          final ValueKey snackBarKey =
              ValueKey<String>('archived-${reminder.id}');
          ScaffoldMessenger.of(context).showSnackBar(buildCustomSnackBar(
              key: snackBarKey,
              content: Row(
                children: [
                  Text("'${reminder.title}' Archived."),
                  const Spacer(),
                  OneTimeUndoButton(
                    onPressed: () {
                      // remindersProviderValue.retrieveFromArchives(reminder);
                    },
                  )
                ],
              )));
        } else {
          final ValueKey snackBarKey = ValueKey<String>('moved-${reminder.id}');
          ScaffoldMessenger.of(context).showSnackBar(buildCustomSnackBar(
              key: snackBarKey,
              content: Row(
                children: [
                  Text("'${reminder.title}' moved to next occurrence."),
                  const Spacer(),
                  OneTimeUndoButton(
                    onPressed: () {
                      remindersProviderValue.moveToPreviousReminderOccurrence(
                          reminder.id ?? reminderNullID);
                    },
                  )
                ],
              )));
        }
      },
    );
  }
}
