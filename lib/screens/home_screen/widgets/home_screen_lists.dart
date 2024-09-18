import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/reminder_sheet/reminder_page.dart';
import 'package:Rem/utils/datetime_methods.dart';
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

  void _slideAndPostponeReminder(BuildContext context, Reminder reminder) {
    reminder.dateAndTime = reminder.dateAndTime.add(Duration(minutes: 10));
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
  }

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
                  startActionPane: ActionPane(
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
                  ),
                  endActionPane: ActionPane(
                    motion: StretchMotion(),
                    children:[
                      SlidableAction(
                        icon: Icons.add,
                        onPressed: (context) 
                          => _slideAndPostponeReminder(context, reminder),
                      )
                    ]
                  ),
                  child: _HomePageReminderEntryListTile(
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


class _HomePageReminderEntryListTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback refreshHomePage;

  const _HomePageReminderEntryListTile({
    super.key,
    required this.reminder,
    required this.refreshHomePage
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListTile(
        title: Text(
          reminder.title,
          style: Theme.of(context).textTheme.titleMedium
        ),
        subtitle: Text(
          getFormattedDateTime(reminder.dateAndTime),
          style: Theme.of(context).textTheme.bodyMedium
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 5,),
            Text(
              getFormattedDiffString(dateTime: reminder.dateAndTime),
              style: Theme.of(context).textTheme.bodySmall
            ),
            if (reminder.recurringInterval != RecurringInterval.none)
            Text(
              "⟳ ${reminder.recurringInterval.name}",
              style: Theme.of(context).textTheme.bodySmall,
            )
          ],
        ),
        tileColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),
        minVerticalPadding: 8,
        minTileHeight: 60,
        onTap: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context, 
            builder: (context) {
              return ReminderSheet(
                thisReminder: reminder, 
                refreshHomePage: refreshHomePage
              );  
            }
          ); 
        },
      ),
    );
  }
}