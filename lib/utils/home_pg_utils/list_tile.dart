import 'package:Rem/pages/reminder_page.dart';
import 'package:Rem/reminder_class/reminder.dart';
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
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 5,),
            Text(
              reminder.getDiffString(),
              style: Theme.of(context).textTheme.bodySmall
            ),
            if (reminder.recurringFrequency != RecurringFrequency.none)
            Text(
              "⟳ ${reminder.recurringFrequency.name}",
              style: Theme.of(context).textTheme.bodySmall,
            )
          ],
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
                refreshHomePage: refreshHomePage
              )
            )
          ); 
        },
      ),
    );
  }
}