import 'package:Rem/provider/archives_provider.dart';
import 'package:Rem/screens/archive_screen/widgets/archived_reminder_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArchiveScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedReminders = ref.watch(archivesProvider).archivedReminders;

    if (archivedReminders.isEmpty) {
      return Scaffold(appBar: getAppBar(context), body: getEmptyPage(context));
    }
    return Scaffold(
      appBar: getAppBar(context),
      body: SingleChildScrollView(
        child: ArchiveEntryLists.ArchivedReminderList(
          remindersList: archivedReminders.values.toList().reversed.toList(),
        ),
      ),
    );
  }

  AppBar getAppBar(BuildContext context) {
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

  Widget getEmptyPage(BuildContext context) {
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
