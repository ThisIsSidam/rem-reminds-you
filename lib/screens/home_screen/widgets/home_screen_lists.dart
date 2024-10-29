import 'package:Rem/consts/consts.dart';
import 'package:Rem/consts/enums/swipe_actions.dart';
import 'package:Rem/database/reminder_database/database.dart';
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
  final VoidCallback refreshPage;

  const HomeScreenReminderListSection({
    super.key,
    this.label,
    required this.remindersList,
    required this.refreshPage,
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
                separatorBuilder: (context, index) => SizedBox(height: 4.0),
                itemBuilder: (context, index) {
                  final SwipeAction leftAction =
                      ref.read(userSettingsProvider).homeTileSwipeActionLeft;
                  final SwipeAction rightAction =
                      ref.read(userSettingsProvider).homeTileSwipeActionRight;
                  final reminder = remindersList[index];

                  return Slidable(
                      key: ValueKey(reminder.id),
                      startActionPane: ActionPaneManager.getActionToRight(
                          rightAction,
                          remindersList,
                          index,
                          context,
                          refreshPage),
                      endActionPane: ActionPaneManager.getActionToLeft(
                          leftAction,
                          remindersList,
                          index,
                          context,
                          refreshPage),
                      child: HomePageReminderEntryListTile(
                          reminder: reminder, refreshHomePage: refreshPage));
                }),
          ),
        ],
      ),
    );
  }
}

mixin ActionPaneManager {
  static ActionPane? getActionToLeft(
      SwipeAction action,
      List<Reminder> remindersList,
      int index,
      BuildContext context,
      void Function() refreshPage) {
    switch (action) {
      case SwipeAction.none:
        return null;
      case SwipeAction.done:
        return _doneActionPane(context, remindersList[index], refreshPage);
      case SwipeAction.delete:
        return _deleteActionPane(remindersList, index, context, refreshPage);
      case SwipeAction.postpone:
        return _postponeActionPane(context, remindersList[index], refreshPage);
      case SwipeAction.doneAndDelete:
        return _doneAndDeleteActionPane(
            context, refreshPage, remindersList, index);
    }
  }

  static ActionPane? getActionToRight(
      SwipeAction action,
      List<Reminder> remindersList,
      int index,
      BuildContext context,
      void Function() refreshPage) {
    switch (action) {
      case SwipeAction.none:
        return null;
      case SwipeAction.done:
        return _doneActionPane(context, remindersList[index], refreshPage);
      case SwipeAction.delete:
        return _deleteActionPane(remindersList, index, context, refreshPage);
      case SwipeAction.postpone:
        return _postponeActionPane(context, remindersList[index], refreshPage);
      case SwipeAction.doneAndDelete:
        return _doneAndDeleteActionPane(
            context, refreshPage, remindersList, index);
    }
  }

  static ActionPane _doneActionPane(
    BuildContext context,
    Reminder reminder,
    void Function() refreshPage,
  ) {
    return ActionPane(
        motion: StretchMotion(),
        children: [_doneSlidableAction(context, reminder, refreshPage)]);
  }

  static ActionPane _deleteActionPane(List<Reminder> remindersList, int index,
      BuildContext context, void Function() refreshPage) {
    final Reminder reminder = remindersList[index];

    return ActionPane(
        motion: StretchMotion(),
        dragDismissible: true,
        dismissible: DismissiblePane(onDismissed: () {
          remindersList.removeAt(index);
          _slideAndRemoveReminder(context, reminder, refreshPage);
        }),
        children: [
          SlidableAction(
              backgroundColor: Colors.red,
              icon: Icons.delete_forever,
              onPressed: (context) {
                remindersList.removeAt(index);
                _slideAndRemoveReminder(context, reminder, refreshPage);
              })
        ]);
  }

  static ActionPane _postponeActionPane(
      BuildContext context, Reminder reminder, void Function() refreshPage) {
    return ActionPane(motion: StretchMotion(), children: [
      Consumer(builder: (context, ref, child) {
        return SlidableAction(
          icon: Icons.add,
          onPressed: (context) {
            final Duration postponeDuration =
                ref.read(userSettingsProvider).defaultPostponeDuration;
            reminder.dateAndTime = reminder.dateAndTime.add(postponeDuration);
            RemindersDatabaseController.saveReminder(reminder);
            refreshPage();

            final ValueKey snackBarKey =
                ValueKey<String>('postponed-${reminder.id}');
            ScaffoldMessenger.of(context).showSnackBar(buildCustomSnackBar(
                key: snackBarKey,
                content: Row(
                  children: [
                    Text("'${reminder.title}' postponed."),
                    Spacer(),
                    OneTimeUndoButton(
                      onPressed: () {
                        reminder.dateAndTime =
                            reminder.dateAndTime.subtract(postponeDuration);
                        RemindersDatabaseController.saveReminder(reminder);
                        refreshPage();
                      },
                    )
                  ],
                )));
          },
        );
      })
    ]);
  }

  static ActionPane _doneAndDeleteActionPane(BuildContext context,
      void Function() refreshPage, List<Reminder> remindersList, int index) {
    final reminder = remindersList[index];

    return ActionPane(motion: StretchMotion(), children: [
      _doneSlidableAction(context, reminder, refreshPage),
      SlidableAction(
          backgroundColor: Colors.red,
          icon: Icons.delete_forever,
          onPressed: (context) {
            remindersList.removeAt(index);
            _slideAndRemoveReminder(context, reminder, refreshPage);
          })
    ]);
  }

  // To be used inside doneActionPane and doneAndDeleteActionPane
  static SlidableAction _doneSlidableAction(
    BuildContext context,
    Reminder reminder,
    void Function() refreshPage,
  ) {
    return SlidableAction(
      backgroundColor: Colors.green,
      icon: Icons.check,
      onPressed: (context) {
        RemindersDatabaseController.markAsDone(reminder.id ?? reminderNullID);
        refreshPage();

        if (reminder.recurringInterval == RecurringInterval.none) {
          final ValueKey snackBarKey =
              ValueKey<String>('archived-${reminder.id}');
          ScaffoldMessenger.of(context).showSnackBar(buildCustomSnackBar(
              key: snackBarKey,
              content: Row(
                children: [
                  Text("'${reminder.title}' Archived."),
                  Spacer(),
                  OneTimeUndoButton(
                    onPressed: () {
                      RemindersDatabaseController.retrieveFromArchives(
                          reminder);
                      refreshPage();
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
                  Spacer(),
                  OneTimeUndoButton(
                    onPressed: () {
                      RemindersDatabaseController
                          .moveToPreviousReminderOccurrence(
                              reminder.id ?? reminderNullID);
                      refreshPage();
                    },
                  )
                ],
              )));
        }
      },
    );
  }

  static void _slideAndRemoveReminder(
      BuildContext context, Reminder reminder, void Function() refreshPage) {
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
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton(
                onPressed: () {
                  RemindersDatabaseController.moveToArchive(reminder.id!);

                  final ValueKey snackBarKey =
                      ValueKey<String>('archived-${reminder.id}');
                  ScaffoldMessenger.of(context)
                      .showSnackBar(buildCustomSnackBar(
                          key: snackBarKey,
                          content: Row(
                            children: [
                              Text("'${reminder.title}' Archived."),
                              Spacer(),
                              OneTimeUndoButton(
                                onPressed: () {
                                  RemindersDatabaseController
                                      .retrieveFromArchives(reminder);
                                  refreshPage();
                                },
                              )
                            ],
                          )));
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'Archive',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton(
                onPressed: () {
                  RemindersDatabaseController.deleteReminder(reminder.id!);

                  ScaffoldMessenger.of(context)
                      .showSnackBar(buildCustomSnackBar(
                          content: Row(
                    children: [
                      Text("'${reminder.title}' deleted"),
                      Spacer(),
                      OneTimeUndoButton(
                        onPressed: () {
                          RemindersDatabaseController.saveReminder(reminder);
                          refreshPage();
                        },
                      )
                    ],
                  )));
                  Navigator.of(context).pop(); // Close the dialog
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
      RemindersDatabaseController.deleteReminder(reminder.id!);

      ScaffoldMessenger.of(context).showSnackBar(buildCustomSnackBar(
          content: Row(
        children: [
          Text("'${reminder.title}' deleted"),
          Spacer(),
          OneTimeUndoButton(
            onPressed: () {
              RemindersDatabaseController.saveReminder(reminder);
              refreshPage();
            },
          )
        ],
      )));
    }
  }
}
