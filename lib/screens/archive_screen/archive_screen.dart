import 'package:Rem/database/archives_database.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/archive_screen/widgets/archived_reminder_list.dart';
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
    final Map<int, Reminder> archivedReminderMap =
        Archives.getArchivedReminders();
    archivedReminders = archivedReminderMap.values.toList();

    super.initState();
  }

  void refreshPage() {
    setState(() {
      archivedReminders = Archives.getArchivedReminders().values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (archivedReminders.isEmpty) {
      return Scaffold(appBar: getAppBar(), body: getEmptyPage());
    }
    return Scaffold(
      appBar: getAppBar(),
      body: SingleChildScrollView(
        child: ArchiveEntryLists.ArchivedReminderList(
          remindersList: archivedReminders.reversed.toList(),
          refreshPage: refreshPage,
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
    ));
  }
}
