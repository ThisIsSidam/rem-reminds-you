import 'package:Rem/utils/home_pg_utils/list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/other_utils/material_container.dart';

class HomePageListSection extends StatelessWidget {
  final String? label;
  final List<Reminder> remindersList;
  final VoidCallback refreshHomePage;

  const HomePageListSection({
    super.key, 
    this.label,
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
          if (label != null)
          MaterialContainer(
            padding: const EdgeInsets.only(
              left: 15, top: 15, bottom: 5
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(label ?? "No Label")
            ),
          ),
          SizedBox(
            height: remindersList.length * 75,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: remindersList.length,
              itemBuilder: (context, index) {
                final reminder = remindersList[index];
                return HomePageReminderEntryListTile(context, reminder, refreshHomePage);
              }
            ),
          ),
        ],
      ),
    );
  }
}