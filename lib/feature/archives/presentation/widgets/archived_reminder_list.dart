import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/data/models/no_rush_reminder/no_rush_reminder.dart';
import '../../../../core/data/models/reminder_model/reminder_model.dart';
import '../../../../shared/utils/datetime_methods.dart';
import '../../../../shared/utils/logger/global_logger.dart';
import '../../../../shared/widgets/snack_bar/custom_snack_bar.dart';
import '../../../reminder_sheet/presentation/sheet_helper.dart';
import '../providers/archives_provider.dart';

class ArchiveEntryLists extends ConsumerWidget {
  const ArchiveEntryLists({
    required this.remindersList,
    super.key,
  });
  final List<ReminderModel> remindersList;

  void _slideAndRemoveReminder(
    BuildContext context,
    ReminderModel reminder,
    WidgetRef ref,
  ) {
    final ArchivesNotifier archivesNotifier = ref.read(archivesProvider)
      ..deleteArchivedReminder(
        reminder.id,
      );
    AppUtils.showToast(
      msg: "'${reminder.title}' deleted",
      description: 'Tap to undo',
      onTap: () {
        archivesNotifier.addReminderToArchives(reminder);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (remindersList.isEmpty) {
      return const SizedBox();
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverList.separated(
        itemCount: remindersList.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: 8),
        itemBuilder: (BuildContext context, int index) {
          final ReminderModel reminder = remindersList[index];

          return Slidable(
            key: ValueKey<int>(reminder.id),
            startActionPane: ActionPane(
              // Same as endActionPane
              motion: const StretchMotion(),
              dismissible: DismissiblePane(
                onDismissed: () {
                  remindersList.removeAt(index);
                  _slideAndRemoveReminder(context, reminder, ref);
                },
              ),
              children: <Widget>[
                SlidableAction(
                  icon: Icons.delete,
                  backgroundColor: Colors.red,
                  onPressed: (BuildContext context) {
                    gLogger.i(
                      'Removing archived reminder with slideAction',
                    );
                    remindersList.removeAt(index);
                    _slideAndRemoveReminder(context, reminder, ref);
                  },
                ),
              ],
            ),
            endActionPane: ActionPane(
              // Same as startActionPane
              motion: const StretchMotion(),
              dismissible: DismissiblePane(
                onDismissed: () {
                  remindersList.removeAt(index);
                  _slideAndRemoveReminder(context, reminder, ref);
                },
              ),
              children: <Widget>[
                SlidableAction(
                  icon: Icons.delete,
                  backgroundColor: Colors.red,
                  onPressed: (BuildContext context) {
                    gLogger.i(
                      'Removing archived reminder with slideAction',
                    );
                    remindersList.removeAt(index);
                    _slideAndRemoveReminder(context, reminder, ref);
                  },
                ),
              ],
            ),
            child: _ArchiveReminderEntryListTile(reminder: reminder),
          );
        },
      ),
    );
  }
}

class _ArchiveReminderEntryListTile extends ConsumerWidget {
  const _ArchiveReminderEntryListTile({required this.reminder});
  final ReminderModel reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        gLogger.i('Show archived reminderSheet | ID: ${reminder.id}');
        SheetHelper().openReminderSheet(
          context,
          reminder: reminder,
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary.withValues(
                alpha: 0.10,
              ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.inversePrimary.withValues(
                  alpha: 0.25,
                ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: double.maxFinite,
                child: Text(
                  reminder.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  softWrap: true,
                ),
              ),
              if (reminder is! NoRushReminderModel)
                Text(
                  getFormattedDateTime(reminder.dateTime),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
