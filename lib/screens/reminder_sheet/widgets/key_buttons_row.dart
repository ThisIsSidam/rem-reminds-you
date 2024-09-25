import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/reminder_sheet/widgets/alert_dialogs/reminder_recurrence.dart';
import 'package:Rem/screens/reminder_sheet/widgets/alert_dialogs/repeat_notif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class KeyButtonsRow extends ConsumerWidget {
  final void Function()? refreshHomePage;
  const KeyButtonsRow({
    super.key,
    required this.refreshHomePage
  });

  void refreshOrExit(BuildContext context) {
    if (refreshHomePage == null)
    {
      Navigator.pop(context);
      return;
    }

    refreshHomePage!();

    Navigator.pop(context);
  }

  void saveReminder(Reminder reminder, BuildContext context) {
    if (reminder.title == "No Title")
    {
      Fluttertoast.showToast(msg: "Enter a title!");
      return;
    }
    if (reminder.dateAndTime.isBefore(DateTime.now()))
    {
      Fluttertoast.showToast(msg: "Time machine is broke. Can't remind you in the past!");
      return;
    }
    RemindersDatabaseController.saveReminder(reminder);
    refreshOrExit(context);
  }

  void deleteReminder(Reminder reminder, BuildContext context) {

    void finalDelete({deleteAllRecurring = false}) {
      RemindersDatabaseController.deleteReminder(
        reminder.id!,
        allRecurringVersions: deleteAllRecurring
      );
      refreshOrExit(context);
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
                  finalDelete(deleteAllRecurring: false);
                  Navigator.of(context).pop(); // Close the dialog
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
    } 
    else 
    {
      finalDelete();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder = ref.watch(reminderNotifierProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ( 
            reminder.id != newReminderID && 
            reminder.reminderStatus != ReminderStatus.archived
          )
          ? MaterialButton(
            child: IconTheme(
              data: Theme.of(context).iconTheme,
              child: const Icon(
                Icons.delete,
                color: Colors.red
              ),
            ),
            onPressed: () => deleteReminder(reminder, context),
          )
          : SizedBox(), // So it shows presence in the Row. And the positions of others do not alter based on presence of done button.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getRepeatNotifButton(context),
              SizedBox(width: 4,),
              getRecurringButton(context),
              SizedBox(width: 4,),
              ElevatedButton(
                onPressed: () => saveReminder(reminder, context),
                child: Text(
                  "Save", 
                  style: Theme.of(context).textTheme.titleMedium
                ),
                style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                  backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor)
                ),
              )
            ],
          ),
        ],
      ),
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
            return RepeatNotifDialog();
          }
        );
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
          }
        );
      }
    );
  }
}