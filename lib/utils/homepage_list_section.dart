import 'package:flutter/material.dart';
import 'package:nagger/utils/reminder.dart';
import 'package:nagger/utils/reminder_tile.dart';

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
            return ReminderTile(
              thisReminder: remindersList[index], 
              refreshFunc: refreshHomePage,
            );
          }
                ),
        ),
      ],
    );
  }
}