import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nagger/reminder_class/reminder.dart';
import 'package:nagger/theme/app_theme.dart';
import 'package:nagger/pages/reminder_page.dart';
import 'package:nagger/utils/other_utils/material_container.dart';

class HomePageListSection extends StatelessWidget {
  final String label;
  final List<Reminder> remindersList;
  final VoidCallback refreshHomePage;

  const HomePageListSection({
    super.key, 
    required this.label,
    required this.remindersList,
    required this.refreshHomePage
  });

  @override
  Widget build(BuildContext context) {
    if (remindersList.isEmpty)
    {
      return const SizedBox.shrink();
    }
    return MaterialContainer(
      elevation: 5,
      child: Column(
        children: [
          MaterialContainer(
            padding: const EdgeInsets.only(
              left: 15, top: 15, bottom: 5
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(label)
            ),
          ),
          SizedBox(
            height: remindersList.length * 75,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: remindersList.length,
              itemBuilder: (context, index) {
                final reminder = remindersList[index];
                return CustomListTile(context, reminder);
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget CustomListTile(BuildContext context, Reminder reminder) {
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
        tileColor: myTheme.cardColor,
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