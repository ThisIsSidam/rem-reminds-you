import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/database/settings/silde_actions.dart';
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
    if (remindersList.isEmpty)
    {
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
            )
          ),
          SizedBox(
            height: remindersList.length * (60+5), // Tile height + separators
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: remindersList.length,
              separatorBuilder: (context, index) => SizedBox(height: 4.0),
              itemBuilder: (context, index) {
                final reminder = remindersList[index];
      
                return Slidable(
                  key: ValueKey(reminder.id),
                  startActionPane: ActionPaneManager.getActionToRight(remindersList, index, context, refreshPage),
                  endActionPane: ActionPaneManager.getActionToLeft(remindersList, index, context, refreshPage),
                  child: HomePageReminderEntryListTile(
                    reminder: reminder, 
                    refreshHomePage:  refreshPage
                  )
                );   
              }
            ),
          ),
        ],
      ),
    );
  } 
}

mixin ActionPaneManager {
  
  static ActionPane getActionToLeft(
    List<Reminder> remindersList,
    int index, 
    BuildContext context,
    void Function() refreshPage
  ) {
    final SlideAction action = UserDB.getSetting(SettingOption.HomeTileSlideAction_ToLeft);
    
    switch (action) {
      case SlideAction.delete: return deleteActionPane(
        remindersList,
        index,
        context,
        refreshPage
      ); 
      case SlideAction.postpone: return postponeActionPane(context, remindersList[index]);
    }
  }

  static ActionPane getActionToRight(
    List<Reminder> remindersList,
    int index, 
    BuildContext context,
    void Function() refreshPage
  ) {
    final SlideAction action = UserDB.getSetting(SettingOption.HomeTileSlideAction_ToRight);
    
    switch (action) {
      case SlideAction.delete: return deleteActionPane(
        remindersList,
        index,
        context,
        refreshPage
      ); 
      case SlideAction.postpone: return postponeActionPane(context, remindersList[index]);
    }
  }

  static ActionPane deleteActionPane(
    List<Reminder> remindersList,
    int index, 
    BuildContext context,
    void Function() refreshPage
  ) {

    final Reminder reminder = remindersList[index];

    void _slideAndRemoveReminder(BuildContext context, Reminder reminder) {
      RemindersDatabaseController.deleteReminder(
        reminder.id ?? reminderNullID,
        // To delete all recurring reminders, user has to open the reminder sheet.
        allRecurringVersions: false 
      );
      refreshPage();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text("'${reminder.title}' archived"),
              Spacer(),
              TextButton(
                child: Text("Undo"),
                onPressed: () {
                  RemindersDatabaseController.saveReminder(reminder);
                  refreshPage();
                },
              )
            ],
          )
        )
      );
    }

    return ActionPane(
      motion: StretchMotion(),
      dragDismissible: true,
      dismissible: DismissiblePane(
        onDismissed: () {
          remindersList.removeAt(index);
          _slideAndRemoveReminder(context, reminder);
        }
      ), 
      children: [
        SlidableAction(
          backgroundColor: Colors.red,
          icon: Icons.archive,
          onPressed: (context) {
            remindersList.removeAt(index);
            _slideAndRemoveReminder(context, reminder);
          }
        )
      ]
    );
  }

  static ActionPane postponeActionPane(
    BuildContext context,
    Reminder reminder
  ) {
    return ActionPane(
      motion: StretchMotion(),
      children:[
        SlidableAction(
          icon: Icons.add,
          onPressed: (context) {
            reminder.dateAndTime = reminder.dateAndTime.add(
              UserDB.getSetting(SettingOption.SlideActionPostponeDuration)
            );
            RemindersDatabaseController.saveReminder(reminder);

            final ValueKey snackBarKey = ValueKey<String>('postponed-${reminder.id}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 2),
                key: snackBarKey,
                content: Row(
                  children: [
                    Text("'${reminder.title}' postponed."),
                    Spacer(),
                    TextButton(
                      child: Text("Undo"),
                      onPressed: () {
                        reminder.dateAndTime = reminder.dateAndTime.subtract(Duration(minutes: 10));
                        RemindersDatabaseController.saveReminder(reminder);
                      },
                    )
                  ],
                )
              )
            );
          },
        )
      ]
    );
  }
}
