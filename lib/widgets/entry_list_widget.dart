import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class EntryListWidget extends StatelessWidget {
  final Widget? label;
  final List<Reminder> remindersList;
  final VoidCallback refreshPage;
  final Widget Function(Reminder, VoidCallback) listEntryWidget;

  const EntryListWidget({
    super.key, 
    this.label,
    required this.remindersList,
    required this.refreshPage,
    required this.listEntryWidget
  });

  void _slideAndRemoveReminder(BuildContext context, Reminder reminder) {
    RemindersDatabaseController.deleteReminder(
      reminder.id ?? reminderNullID,
      // To delete all recurring reminders, user has to open the reminder sheet.
      allRecurringVersions: false 
    );

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
                        icon: Icons.archive,
                        onPressed: (context) {
                          remindersList.removeAt(index);
                          _slideAndRemoveReminder(context, reminder);
                        }
                      )
                    ]
                  ),
                  child: listEntryWidget(reminder, refreshPage)
                );   
              }
            ),
          ),
        ],
      ),
    );
  }

  
}