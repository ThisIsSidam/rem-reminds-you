import 'package:flutter/material.dart';
import 'package:nagger/utils/reminder.dart';
import 'package:nagger/utils/reminder_tile.dart';

class HomePageListSection extends StatelessWidget {
  final String name;
  final List<Reminder> remindersList;
  final VoidCallback refreshHomePage;

  HomePageListSection({
    super.key, 
    required this.name,
    required this.remindersList,
    required this.refreshHomePage
  }){
    print("--------------\n$name-----------");
    for (final i in remindersList)
    {
        print(i.getId());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (remindersList.isEmpty)
    {
      return const SizedBox.shrink();
    }
    
    return Column(
      children: [
        SizedBox(
          child: Text(name),
        ),
        SizedBox(
          height: remindersList.length * 70,
          child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: remindersList.length,
          separatorBuilder: (context, index) {
            return const Divider(
              color: Colors.black,
              height: 2,
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