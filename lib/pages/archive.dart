import 'package:Rem/database/database.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/home_pg_utils/homepage_list_section.dart';
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
    
    final Map<int, Reminder> archivedReminderMap = RemindersDatabaseController.getArchives();
    archivedReminders = archivedReminderMap.values.toList();

    super.initState();
  }

  void refreshPage() {
    setState(() {
      archivedReminders = RemindersDatabaseController.getArchives().values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Archive"),
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: HomePageListSection(
        remindersList: archivedReminders,
        refreshHomePage: refreshPage,
      )
    );
  }
}