import 'package:Rem/consts/consts.dart';
import 'package:Rem/models/reminder_model/reminder_model.dart';
import 'package:Rem/provider/reminders_provider.dart';
import 'package:Rem/screens/reminder_sheet/providers/bottom_element_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../models/recurring_interval/recurring_interval.dart';
import '../../../models/recurring_reminder/recurring_reminder.dart';
import '../../../provider/archives_provider.dart';
import '../../../provider/sheet_reminder_notifier.dart';

class KeyButtonsRow extends ConsumerWidget {
  const KeyButtonsRow({
    super.key,
  });

  void saveReminder(BuildContext context, WidgetRef ref) async {
    final ReminderModel reminder =
        ref.read(sheetReminderNotifier).constructReminder();

    if (reminder.title == "No Title") {
      Fluttertoast.showToast(msg: "Enter a title!");
      return;
    }
    if (reminder.dateTime.isBefore(DateTime.now())) {
      Fluttertoast.showToast(
          msg: "Time machine is broke. Can't remind you in the past!");
      return;
    }

    if ((await ref.read(archivesProvider).isInArchives(reminder.id))) {
      ref.read(remindersProvider).retrieveFromArchives(reminder.id);
    } else {
      ref.read(remindersProvider).saveReminder(reminder);
    }
    Navigator.pop(context);
  }

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
    final noRush = ref.watch(sheetReminderNotifier.select((p) => p.noRush));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (id != null) ...<Widget>[
            IconButton(
              icon: IconTheme(
                data: Theme.of(context).iconTheme,
                child: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.errorContainer,
                ),
              ),
              onPressed: () => deleteReminder(id, context, ref),
            ),
            Spacer(),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!noRush) _buildSnoozeOptionsDialogButton(context, ref),
              if (!noRush) _buildRecurrenceOptionsDialogButton(context, ref),
              _buildSaveButton(context, ref)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, WidgetRef ref) {
    final reminder = ref.read(sheetReminderNotifier);

    bool forAllCondition = reminder.id != newReminderID &&
        reminder is RecurringReminderModel &&
        reminder.recurringInterval != RecurringInterval.none &&
        !reminder.dateTime.isAtSameMomentAs(reminder.baseDateTime);

    return Row(
      children: [
        ElevatedButton(
          child: Text(
            "Save",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
          onPressed: () => saveReminder(context, ref),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              surfaceTintColor: Colors.transparent,
              shape: forAllCondition
                  ? RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.horizontal(left: Radius.circular(25)))
                  : null),
        ),
        if (forAllCondition)
          ElevatedButton(
            onPressed: () {
              saveReminder(context, ref);
            },
            child: Text("For All",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(25)))),
          ),
      ],
    );
  }

  Widget _buildSnoozeOptionsDialogButton(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(bottomElementProvider.notifier);
    return IconButton(
      icon: Icon(Icons.snooze),
      style: IconButton.styleFrom(
        backgroundColor:
            provider.element == ReminderSheetBottomElement.snoozeOptions
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
      ),
      onPressed: () {
        if (provider.element != ReminderSheetBottomElement.snoozeOptions) {
          provider.element = ReminderSheetBottomElement.snoozeOptions;
        }
      },
    );
  }

  Widget _buildRecurrenceOptionsDialogButton(
    BuildContext context,
    WidgetRef ref,
  ) {
    final provider = ref.watch(bottomElementProvider.notifier);
    return IconButton(
        icon: Icon(Icons.event_repeat),
        style: IconButton.styleFrom(
          backgroundColor:
              provider.element == ReminderSheetBottomElement.recurrenceOptions
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
        ),
        onPressed: () {
          if (provider.element !=
              ReminderSheetBottomElement.recurrenceOptions) {
            ref.read(bottomElementProvider).element =
                ReminderSheetBottomElement.recurrenceOptions;
          }
        });
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
