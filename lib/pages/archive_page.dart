import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/entry_list_widget.dart';
import 'package:flutter/material.dart';

class Archive extends StatefulWidget {
  const Archive({super.key});

  @override
  State<Archive> createState() => _ArchiveState();
}

class _ArchiveState extends State<Archive> {
  List<Reminder> archivedReminders = [];

  @override
  void initState() {
    
    final Map<int, Reminder> archivedReminderMap = RemindersDatabaseController.getReminders(key: archivesKey);
    archivedReminders = archivedReminderMap.values.toList();

    super.initState();
  }

  void refreshPage() {
    setState(() {
      archivedReminders = RemindersDatabaseController.getReminders(key: archivesKey).values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Archive",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
          ),
          style: Theme.of(context).iconButtonTheme.style,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: archivedReminders.isEmpty
      ? getEmptyPageBody() 
      : HomePageListSection(
        remindersList: archivedReminders,
        refreshHomePage: refreshPage,
      )
    );
  }

  Widget getEmptyPageBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No archived reminders",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      )
    );
  }
}