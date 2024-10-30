import 'package:Rem/consts/consts.dart';
import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:Rem/provider/reminders_provider.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/reminder_sheet/widgets/alert_dialogs/reminder_recurrence.dart';
import 'package:Rem/screens/reminder_sheet/widgets/alert_dialogs/repeat_notif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../reminder_class/field_mixins/reminder_status/status.dart';

class KeyButtonsRow extends ConsumerWidget {
  const KeyButtonsRow({
    super.key,
  });

  void saveReminder(Reminder reminder, BuildContext context, WidgetRef ref) {
    if (reminder.title == "No Title") {
      Fluttertoast.showToast(msg: "Enter a title!");
      return;
    }
    if (reminder.dateAndTime.isBefore(DateTime.now())) {
      Fluttertoast.showToast(
          msg: "Time machine is broke. Can't remind you in the past!");
      return;
    }

    if (reminder.reminderStatus == ReminderStatus.archived) {
      ref.read(remindersProvider).retrieveFromArchives(reminder.id);
    } else {
      ref.read(remindersProvider).saveReminder(reminder);
    }
    Navigator.pop(context);
  }

  void deleteReminder(Reminder reminder, BuildContext context, WidgetRef ref) {
    void finalDelete({deleteAllRecurring = false}) {
      ref.read(remindersProvider).deleteReminder(
            reminder.id,
          );
      Navigator.pop(context);
    }

    if (reminder.recurringInterval != RecurringInterval.none) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
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
                  ref.read(remindersProvider).moveToArchive(reminder.id);
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
        },
      );
    } else {
      finalDelete();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder = ref.watch(reminderNotifierProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (reminder.id != newReminderID &&
              reminder.reminderStatus != ReminderStatus.archived) ...<Widget>[
            IconButton(
              icon: IconTheme(
                data: Theme.of(context).iconTheme,
                child: const Icon(Icons.delete, color: Colors.red),
              ),
              onPressed: () => deleteReminder(reminder, context, ref),
            ),
            Spacer(),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getRepeatNotifButton(context),
              SizedBox(
                width: 4,
              ),
              getRecurringButton(context),
              SizedBox(
                width: 4,
              ),
              _buildSaveButton(context, reminder, ref)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(
      BuildContext context, Reminder reminder, WidgetRef ref) {
    bool forAllCondition = reminder.id != newReminderID &&
        reminder.recurringInterval != RecurringInterval.none &&
        !reminder.dateAndTime.isAtSameMomentAs(reminder.baseDateTime);

    return Row(
      children: [
        ElevatedButton(
          child: Text("Save",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Theme.of(context).colorScheme.onPrimary)),
          onPressed: () => saveReminder(reminder, context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        if (forAllCondition)
          ElevatedButton(
            onPressed: () {
              reminder.baseDateTime = reminder.dateAndTime;
              saveReminder(reminder, context, ref);
            },
            child: Text("For All",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Theme.of(context).colorScheme.onPrimary)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              surfaceTintColor: Colors.transparent,
            ),
          ),
      ],
    );
  }

  Widget getRepeatNotifButton(BuildContext context) {
    return ElevatedButton(
      child: Icon(Icons.snooze),
      style: Theme.of(context).elevatedButtonTheme.style,
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return SnoozeOptionsDialog();
            });
      },
    );
  }

  Widget getRecurringButton(BuildContext context) {
    return ElevatedButton(
        child: Icon(Icons.event_repeat_outlined),
        style: Theme.of(context).elevatedButtonTheme.style,
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return ReminderRecurrenceDialog();
              });
        });
  }
}
