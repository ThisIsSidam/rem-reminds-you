import 'package:Rem/feature/archives/presentation/providers/archives_provider.dart';
import 'package:Rem/feature/archives/presentation/widgets/archived_reminder_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../shared/utils/logger/global_logger.dart';

class ArchiveScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      gLogger.i('Built Archives Sheet');
      return null;
    }, []);

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
