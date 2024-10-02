import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/archives_database.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/reminder_sheet/reminder_sheet.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:Rem/widgets/snack_bar/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ArchiveEntryLists extends StatelessWidget {
  final Widget? label;
  final List<Reminder> remindersList;
  final VoidCallback refreshPage;

  const ArchiveEntryLists.ArchivedReminderList({
    super.key, 
    this.label,
    required this.remindersList,
    required this.refreshPage,
  });

  void _slideAndRemoveReminder(BuildContext context, Reminder reminder) {
    Archives.deleteArchivedReminder(
      reminder.id ?? reminderNullID,
    );
    refreshPage();

    ScaffoldMessenger.of(context).showSnackBar(
      buildCustomSnackBar(
        content: Row(
          children: [
            Text("'${reminder.title}' deleted"),
            Spacer(),
            TextButton(
              child: Text("Undo"),
              onPressed: () {
                Archives.addReminderToArchives(reminder);
                refreshPage();
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
                        icon: Icons.delete,
                        backgroundColor: Colors.red,
                        onPressed: (context) {
                          remindersList.removeAt(index);
                          _slideAndRemoveReminder(context, reminder);
                        }
                      )
                    ]
                  ),
                  child: _ArchiveReminderEntryListTile(
                    reminder: reminder,
                    refreshPage: refreshPage
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

class _ArchiveReminderEntryListTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback refreshPage;

  const _ArchiveReminderEntryListTile({
    super.key,
    required this.reminder,
    required this.refreshPage
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
        trailing: IconButton(
          icon: Icon(Icons.delete),
          style: Theme.of(context).iconButtonTheme.style,
          onPressed: onTapDelete,
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
                refreshHomePage: refreshPage
              );  
            }
          ); 
        },
      ),
    );
  }

  void onTapDelete() {
    if (reminder.id == null) {
      throw "Couldn't fetch reminder id";
    }
    Archives.deleteArchivedReminder(reminder.id ?? reminderNullID);
    refreshPage();
  }
}