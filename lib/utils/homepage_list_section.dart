import 'package:flutter/material.dart';
import 'package:nagger/reminder_class/reminder.dart';
import 'package:nagger/theme/app_theme.dart';
import 'package:nagger/pages/reminder_page.dart';

class HomePageListSection extends StatelessWidget {
  final String name;
  final List<Reminder> remindersList;
  final VoidCallback refreshHomePage;

  const HomePageListSection({
    super.key, 
    required this.name,
    required this.remindersList,
    required this.refreshHomePage
  });

  @override
  Widget build(BuildContext context) {
    if (remindersList.isEmpty)
    {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(name)
          ),
        ),
        const SizedBox(height: 5,),
        SizedBox(
          height: remindersList.length * 75,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: remindersList.length,
            separatorBuilder: (context, index) {
              return const Divider(
                color: Colors.transparent,
                height: 5,
              );
            },
            itemBuilder: (context, index) {
              final reminder = remindersList[index];
              return CustromListTile(context, reminder);
            }
          ),
        ),
      ],
    );
  }

  Widget CustromListTile(BuildContext context, Reminder reminder) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10, right: 10
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
          children: [
            SizedBox(height: 5,),
            Text(
              reminder.getDiffString(),
              style: Theme.of(context).textTheme.bodySmall
            ),
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