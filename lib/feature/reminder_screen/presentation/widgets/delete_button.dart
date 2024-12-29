import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/recurring_interval/recurring_interval.dart';
import '../../../archives/presentation/providers/archives_provider.dart';
import '../../../home/presentation/providers/reminders_provider.dart';
import '../providers/sheet_reminder_notifier.dart';

class DeleteReminderButton extends ConsumerWidget {
  const DeleteReminderButton({super.key});

  void deleteReminder(
    int id,
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (await ref.read(archivesProvider).isInArchives(id)) {
      ref.read(archivesProvider).deleteArchivedReminder(id);
      return;
    }

    void finalDelete({deleteAllRecurring = false}) {
      ref.read(remindersProvider).deleteReminder(
            id,
          );
      Navigator.pop(context);
    }

    final recurringInterval = ref.read(sheetReminderNotifier).recurringInterval;

    if (recurringInterval != RecurringInterval.none) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return _RecurringReminderDeletionDialog(
            finalDelete: finalDelete,
          );
        },
      );
    } else {
      finalDelete();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(sheetReminderNotifier.select((p) => p.id));

    if (id == null) return SizedBox.shrink();

    return RawMaterialButton(
      constraints: BoxConstraints(maxWidth: 48),
      child: Icon(Icons.delete),
      fillColor: Theme.of(context).colorScheme.errorContainer,
      onPressed: () => deleteReminder(id, context, ref),
      padding: EdgeInsets.all(8),
      shape: CircleBorder(),
    );
    ;
  }
}

class _RecurringReminderDeletionDialog extends ConsumerWidget {
  const _RecurringReminderDeletionDialog({required this.finalDelete});

  final Function({bool deleteAllRecurring}) finalDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(sheetReminderNotifier.select((p) => p.id));
    return AlertDialog(
      elevation: 5,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Theme.of(context).cardColor,
      title: Text(
        'Recurring Reminder',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Text(
        'This is a recurring reminder. Do you really want to delete it? You can also archive it.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        TextButton(
          onPressed: () {
            ref.read(remindersProvider).moveToArchive(id!);
            Navigator.of(context).pop(); // Close the dialog
            Navigator.pop(context);
          },
          child: Text(
            'Archive',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        TextButton(
          onPressed: () {
            finalDelete(deleteAllRecurring: true);
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text(
            'Delete',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}
