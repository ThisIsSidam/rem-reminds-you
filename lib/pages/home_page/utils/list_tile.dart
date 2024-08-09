import 'package:Rem/pages/reminder_page/reminder_page.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/functions/datetime_methods.dart';
import 'package:flutter/material.dart';

class HomePageReminderEntryListTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback refreshHomePage;

  const HomePageReminderEntryListTile({
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
              return ReminderPage(
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