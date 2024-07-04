import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/archives_database.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/archive_utils/list_tile.dart';
import 'package:Rem/utils/entry_list_widget.dart';
import 'package:flutter/material.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  List<Reminder> archivedReminders = [];

  @override
  void initState() {
    
    final Map<int, Reminder> archivedReminderMap = ArchivesDatabase.getArchivedReminders();
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
      : EntryListWidget(
        remindersList: archivedReminders,
        refreshHomePage: refreshPage,
        listEntryWidget: (Reminder rem, VoidCallback func)
          => ArchiveReminderEntryListTile(reminder: rem, refreshHomePage: func),
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