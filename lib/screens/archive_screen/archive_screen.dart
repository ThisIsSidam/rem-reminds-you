import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/archives_database.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/archive_screen/widgets/list_tile.dart';
import 'package:Rem/widgets/entry_list_widget.dart';
import 'package:flutter/material.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
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

    if (archivedReminders.isEmpty)
    {
      return Scaffold(
        appBar: getAppBar(),
        body: getEmptyPage()
      );
    }
    return Scaffold(
      appBar: getAppBar(),
      body: SingleChildScrollView(
        child: EntryListWidget(
          remindersList: archivedReminders.reversed.toList(),
          refreshPage: refreshPage,
          listEntryWidget: (Reminder rem, VoidCallback func)
            => ArchiveReminderEntryListTile(reminder: rem, refreshPage: func),
        ),
      ),
    );
  }

  AppBar getAppBar() {
    return AppBar(
      surfaceTintColor: null,
      // toolbarHeight: ,
      backgroundColor: Colors.transparent,
      title: Text(
        "Archive",
        style: Theme.of(context).textTheme.titleLarge,
      ),
      
    );
  }

  Widget getEmptyPage() {
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