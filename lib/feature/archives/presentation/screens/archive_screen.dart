import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/data/models/reminder_model/reminder_model.dart';
import '../../../../shared/utils/logger/global_logger.dart';
import '../providers/archives_provider.dart';
import '../widgets/archived_reminder_list.dart';

class ArchiveScreen extends HookConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        gLogger.i('Built Archives Sheet');
        return null;
      },
      <Object?>[],
    );

    final Map<int, ReminderModel> archivedReminders =
        ref.watch(archivesProvider).archivedReminders;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          getAppBar(context),
          if (archivedReminders.isEmpty)
            getEmptyPage(context)
          else
            ArchiveEntryLists(
              remindersList:
                  archivedReminders.values.toList().reversed.toList(),
            ),
        ],
      ),
    );
  }

  SliverAppBar getAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        'Archive',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget getEmptyPage(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.archive,
              size: 150,
            ),
            Text(
              'No archived reminders',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
