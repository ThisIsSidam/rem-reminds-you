import 'package:Rem/feature/archives/presentation/providers/archives_provider.dart';
import 'package:Rem/feature/reminder_screen/presentation/screens/reminder_screen.dart';
import 'package:Rem/shared/utils/datetime_methods.dart';
import 'package:Rem/shared/widgets/snack_bar/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/models/basic_reminder_model.dart';
import '../../../../core/models/no_rush_reminder/no_rush_reminders_model.dart';
import '../../../../shared/utils/logger/global_logger.dart';

class ArchiveEntryLists extends ConsumerWidget {
  final List<BasicReminderModel> remindersList;

  const ArchiveEntryLists({
    super.key,
    required this.remindersList,
  });

  void _slideAndRemoveReminder(
      BuildContext context, BasicReminderModel reminder, WidgetRef ref) {
    final archivesNotifier = ref.read(archivesProvider);
    archivesNotifier.deleteArchivedReminder(
      reminder.id,
    );

    ScaffoldMessenger.of(context).showSnackBar(buildCustomSnackBar(
        content: Row(
      children: [
        Text("'${reminder.title}' deleted"),
        Spacer(),
        TextButton(
          child: Text("Undo"),
          onPressed: () {
            archivesNotifier.addReminderToArchives(reminder);
          },
        )
      ],
    )));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (remindersList.isEmpty) {
      return const SizedBox();
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      sliver: SliverList.separated(
          itemCount: remindersList.length,
          separatorBuilder: (context, index) => SizedBox(height: 8.0),
          itemBuilder: (context, index) {
            final reminder = remindersList[index];

            return Slidable(
                key: ValueKey(reminder.id),
                startActionPane: ActionPane(
                    // Same as endActionPane
                    motion: StretchMotion(),
                    dragDismissible: true,
                    dismissible: DismissiblePane(onDismissed: () {
                      remindersList.removeAt(index);
                      _slideAndRemoveReminder(context, reminder, ref);
                    }),
                    children: [
                      SlidableAction(
                          icon: Icons.delete,
                          backgroundColor: Colors.red,
                          onPressed: (context) {
                            gLogger.i(
                                'Removing archived reminder with slideAction');
                            remindersList.removeAt(index);
                            _slideAndRemoveReminder(context, reminder, ref);
                          })
                    ]),
                endActionPane: ActionPane(
                    // Same as startActionPane
                    motion: StretchMotion(),
                    dragDismissible: true,
                    dismissible: DismissiblePane(onDismissed: () {
                      remindersList.removeAt(index);
                      _slideAndRemoveReminder(context, reminder, ref);
                    }),
                    children: [
                      SlidableAction(
                          icon: Icons.delete,
                          backgroundColor: Colors.red,
                          onPressed: (context) {
                            gLogger.i(
                                'Removing archived reminder with slideAction');
                            remindersList.removeAt(index);
                            _slideAndRemoveReminder(context, reminder, ref);
                          })
                    ]),
                child: _ArchiveReminderEntryListTile(reminder: reminder));
          }),
    );
  }
}

class _ArchiveReminderEntryListTile extends ConsumerWidget {
  final BasicReminderModel reminder;

  const _ArchiveReminderEntryListTile({required this.reminder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        gLogger.i('Show archived reminderSheet | ID: ${reminder.id}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReminderScreen(reminder: reminder),
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.maxFinite,
                child: Text(
                  reminder.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  softWrap: true,
                ),
              ),
              if (reminder is! NoRushRemindersModel)
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
