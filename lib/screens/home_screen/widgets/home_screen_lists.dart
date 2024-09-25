import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/database/settings/swipe_actions.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/home_screen/widgets/list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomeScreenReminderListSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                  final reminder = remindersList[index];

                  return Slidable(
                      key: ValueKey(reminder.id),
                      startActionPane: ActionPaneManager.getActionToRight(
                          remindersList, index, context, refreshPage),
                      endActionPane: ActionPaneManager.getActionToLeft(
                          remindersList, index, context, refreshPage),
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
  static ActionPane? getActionToLeft(List<Reminder> remindersList, int index,
      BuildContext context, void Function() refreshPage) {
    final SwipeAction action =
        UserDB.getSetting(SettingOption.HomeTileSlideAction_ToLeft);

    switch (action) {
      case SwipeAction.none:
        return null;
      case SwipeAction.done:
        return doenActionPane(context, remindersList[index], refreshPage);
      case SwipeAction.delete:
        return deleteActionPane(remindersList, index, context, refreshPage);
      case SwipeAction.postpone:
        return postponeActionPane(context, remindersList[index], refreshPage);
      case SwipeAction.doneAndDelete:
        return null;
    }
  }

  static ActionPane? getActionToRight(List<Reminder> remindersList, int index,
      BuildContext context, void Function() refreshPage) {
    final SwipeAction action =
        UserDB.getSetting(SettingOption.HomeTileSlideAction_ToRight);

    switch (action) {
      case SwipeAction.none:
        return null;
      case SwipeAction.done:
        return doenActionPane(context, remindersList[index], refreshPage);
      case SwipeAction.delete:
        return deleteActionPane(remindersList, index, context, refreshPage);
      case SwipeAction.postpone:
        return postponeActionPane(context, remindersList[index], refreshPage);
      case SwipeAction.doneAndDelete:
        return null;
    }
  }

  static ActionPane deleteActionPane(List<Reminder> remindersList, int index,
      BuildContext context, void Function() refreshPage) {
    final Reminder reminder = remindersList[index];

    void _slideAndRemoveReminder(BuildContext context, Reminder reminder) {
      RemindersDatabaseController.deleteReminder(reminder.id ?? reminderNullID,
          // To delete all recurring reminders, user has to open the reminder sheet.
          allRecurringVersions: false);
      refreshPage();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
        children: [
          Text("'${reminder.title}' deleted"),
          Spacer(),
          TextButton(
            child: Text("Undo"),
            onPressed: () {
              RemindersDatabaseController.saveReminder(reminder);
              refreshPage();
            },
          )
        ],
      )));
    }

    return ActionPane(
        motion: StretchMotion(),
        dragDismissible: true,
        dismissible: DismissiblePane(onDismissed: () {
          remindersList.removeAt(index);
          _slideAndRemoveReminder(context, reminder);
        }),
        children: [
          SlidableAction(
              backgroundColor: Colors.red,
              icon: Icons.delete_forever,
              onPressed: (context) {
                remindersList.removeAt(index);
                _slideAndRemoveReminder(context, reminder);
              })
        ]);
  }

  static ActionPane postponeActionPane(
      BuildContext context, Reminder reminder, void Function() refreshPage) {
    return ActionPane(motion: StretchMotion(), children: [
      SlidableAction(
        icon: Icons.add,
        onPressed: (context) {
          final Duration postponeDuration = UserDB.getSetting(SettingOption.SlideActionPostponeDuration);
          reminder.dateAndTime = reminder.dateAndTime.add(postponeDuration);
          RemindersDatabaseController.saveReminder(reminder);
          refreshPage();

          final ValueKey snackBarKey =
              ValueKey<String>('postponed-${reminder.id}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 2),
              key: snackBarKey,
              content: Row(
                children: [
                  Text("'${reminder.title}' postponed."),
                  Spacer(),
                  TextButton(
                    child: Text("Undo"),
                    onPressed: () {
                      reminder.dateAndTime =
                          reminder.dateAndTime.subtract(postponeDuration);
                      RemindersDatabaseController.saveReminder(reminder);
                      refreshPage();
                    },
                  )
                ],
              )
            )
          );
        },
      )
    ]);
  }

  static ActionPane doenActionPane(
    BuildContext context,
    Reminder reminder,
    void Function() refreshPage,
  ) {

    return ActionPane(
      motion: StretchMotion(), 
      children: [
        SlidableAction(
          backgroundColor: Colors.green,
          icon: Icons.check,
          onPressed: (context) {
            RemindersDatabaseController.markAsDone(reminder.id ?? reminderNullID);
            refreshPage();

            if (reminder.recurringInterval == RecurringInterval.none) {
              final ValueKey snackBarKey =
                  ValueKey<String>('archived-${reminder.id}');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 2),
                  key: snackBarKey,
                  content: Row(
                    children: [
                      Text("'${reminder.title}' Archived."),
                      Spacer(),
                      TextButton(
                        child: Text("Undo"),
                        onPressed: () {
                          RemindersDatabaseController.retrieveFromArchives(reminder);
                          refreshPage();
                        },
                      )
                    ],
                  )
                )
              );
            } else {
              final ValueKey snackBarKey = 
                ValueKey<String>('moved-${reminder.id}');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 2),
                  key: snackBarKey,
                  content: Row(
                    children: [
                      Text("'${reminder.title}' moved to next occurrence."),
                      Spacer(),
                      TextButton(
                        child: Text("Undo"),
                        onPressed: () {
                          RemindersDatabaseController.moveToPreviousReminderOccurence(reminder.id ?? reminderNullID);
                          refreshPage();
                        },
                      )
                    ],
                  )
                )
              );
            }

          },
        )
      ]
    );
  }
}
