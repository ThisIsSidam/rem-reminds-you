import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/archives_database.dart';
import 'package:Rem/pages/reminder_page.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:flutter/material.dart';

class ArchiveReminderEntryListTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback refreshPage;

  const ArchiveReminderEntryListTile({
    super.key,
    required this.reminder,
    required this.refreshPage
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 0, right: 0
      ),
      child: ListTile(
        title: Text(
          reminder.title,
          style: Theme.of(context).textTheme.titleMedium
        ),
        subtitle: Text(
          reminder.getDateTimeAsStr(),
          style: Theme.of(context).textTheme.bodyMedium
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          style: Theme.of(context).iconButtonTheme.style,
          onPressed: onTapDelete,
        ),
        tileColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)
        ),

        onTap: () {
          Navigator.push(context, 
            MaterialPageRoute(
              builder: (context) => ReminderPage(
                thisReminder: reminder, 
                refreshHomePage: refreshPage
              )
            )
          ); 
        },
      ),
    );
  }

  void onTapDelete() {
    if (reminder.id == null) {
      throw "Couldn't fetch reminder id";
    }
    ArchivesDatabase.deleteArchivedReminder(reminder.id ?? reminderNullID);
    refreshPage();
  }
}