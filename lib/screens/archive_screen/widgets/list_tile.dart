import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/archives_database.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/reminder_sheet/reminder_page.dart';
import 'package:Rem/utils/datetime_methods.dart';
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