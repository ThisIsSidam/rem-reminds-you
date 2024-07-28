import 'package:Rem/consts/const_colors.dart';
import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/archives_database.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/archive_utils/list_tile.dart';
import 'package:Rem/utils/other_utils/entry_list_widget.dart';
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

    if (archivedReminders.isEmpty)
    {
      return Scaffold(
        appBar: AppBar(
          surfaceTintColor: null,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        body: getEmptyPage()
      );
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        shadowColor: ConstColors.darkGrey,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: EntryListWidget(
          remindersList: archivedReminders,
          refreshPage: refreshPage,
          listEntryWidget: (Reminder rem, VoidCallback func)
            => ArchiveReminderEntryListTile(reminder: rem, refreshPage: func),
        ),
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