import 'package:Rem/provider/archives_provider.dart';
import 'package:Rem/screens/archive_screen/widgets/archived_reminder_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArchiveScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedReminders = ref.watch(archivesProvider).archivedReminders;

    return Scaffold(
        body: CustomScrollView(
      slivers: [
        getAppBar(context),
        archivedReminders.isEmpty
            ? getEmptyPage(context)
            : ArchiveEntryLists(
                remindersList:
                    archivedReminders.values.toList().reversed.toList(),
              ),
      ],
    ));
  }

  SliverAppBar getAppBar(BuildContext context) {
    return SliverAppBar(
      surfaceTintColor: null,
      backgroundColor: Colors.transparent,
      title: Text(
        "Archive",
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget getEmptyPage(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive,
            size: 150,
          ),
          Text(
            "No archived reminders",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      )),
    );
  }
}
