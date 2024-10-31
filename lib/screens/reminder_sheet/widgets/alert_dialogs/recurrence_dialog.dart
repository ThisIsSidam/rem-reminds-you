import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/reminder_sheet/widgets/base_versions/alert_dialog_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReminderRecurrenceDialog extends ConsumerWidget {
  ReminderRecurrenceDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialogBase(
      title: "Recurrence Options",
      tooltipMsg:
          "Reminder is repeat on either daily or weekly basis. Monthly and More are coming soon.",
      content: SizedBox(
          height: 250, width: 375, child: getButtonsGrid(context, ref)),
    );
  }

  Widget getButtonsGrid(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: GridView.count(
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        crossAxisCount: 2,
        shrinkWrap: true,
        childAspectRatio: 1.5,
        children: [
          intervalButton(RecurringInterval.none, context, ref),
          intervalButton(RecurringInterval.daily, context, ref),
          intervalButton(RecurringInterval.weekly, context, ref),
          intervalButton(RecurringInterval.custom, context, ref),
        ],
      ),
    );
  }

  Widget intervalButton(
      RecurringInterval interval, BuildContext context, WidgetRef ref) {
    final reminder = ref.read(reminderNotifierProvider);
    bool isPickedOption = interval == reminder.recurringInterval;

    return ElevatedButton(
      onPressed: () {
        if (interval == RecurringInterval.custom) {
          Fluttertoast.showToast(msg: "Coming soon!");
          return;
        }
        reminder.recurringInterval = interval;
        ref.read(reminderNotifierProvider.notifier).updateReminder(reminder);
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(4),
        shape: BeveledRectangleBorder(),
        backgroundColor: isPickedOption
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Text(
        interval.toString(),
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: isPickedOption
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSecondaryContainer),
      ),
    );
  }
}
