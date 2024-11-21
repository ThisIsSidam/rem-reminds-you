import 'package:Rem/provider/archives_provider.dart';
import 'package:Rem/screens/reminder_sheet/reminder_sheet.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:Rem/widgets/snack_bar/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../modals/reminder_modal/reminder_modal.dart';
import '../../../utils/logger/global_logger.dart';

class ArchiveEntryLists extends ConsumerWidget {
  final List<ReminderModal> remindersList;

  const ArchiveEntryLists({
    super.key,
    required this.remindersList,
  });

  void _slideAndRemoveReminder(
      BuildContext context, ReminderModal reminder, WidgetRef ref) {
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
  final ReminderModal reminder;

  const _ArchiveReminderEntryListTile({required this.reminder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title:
          Text(reminder.title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(getFormattedDateTime(reminder.dateTime),
          style: Theme.of(context).textTheme.bodyMedium),
      tileColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      minVerticalPadding: 8,
      minTileHeight: 60,
      onTap: () {
        gLogger.i('Show archived reminderSheet | ID: ${reminder.id}');
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return ReminderSheet(
                reminder: reminder,
              );
            });
      },
    );
  }
}
