import 'package:Rem/provider/archives_provider.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/reminder_sheet/reminder_sheet.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:Rem/widgets/snack_bar/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ArchiveEntryLists extends ConsumerWidget {
  final List<Reminder> remindersList;

  const ArchiveEntryLists({
    super.key,
    required this.remindersList,
  });

  void _slideAndRemoveReminder(
      BuildContext context, Reminder reminder, WidgetRef ref) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
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
  final Reminder reminder;

  const _ArchiveReminderEntryListTile({required this.reminder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title:
          Text(reminder.title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(getFormattedDateTime(reminder.dateAndTime),
          style: Theme.of(context).textTheme.bodyMedium),
      tileColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      minVerticalPadding: 8,
      minTileHeight: 60,
      onTap: () {
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return ReminderSheet(
                thisReminder: reminder,
              );
            });
      },
    );
  }
}
