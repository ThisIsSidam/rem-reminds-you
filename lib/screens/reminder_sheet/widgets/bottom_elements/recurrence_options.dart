import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../modals/recurring_interval/recurring_interval.dart';
import '../../providers/bottom_element_provider.dart';

class ReminderRecurrenceOptionsWidget extends ConsumerWidget {
  ReminderRecurrenceOptionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Recurrence Options",
                style: Theme.of(context).textTheme.titleMedium),
          ),
          getButtonsGrid(context, ref)
        ]);
  }

  Widget getButtonsGrid(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: GridView.count(
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        crossAxisCount: 2,
        shrinkWrap: true,
        childAspectRatio: 2,
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
    final recurringInterval =
        ref.read(reminderNotifierProvider).recurringInterval;
    bool isPickedOption = interval == recurringInterval;

    return ElevatedButton(
      onPressed: () {
        if (interval == RecurringInterval.custom) {
          Fluttertoast.showToast(msg: "Coming soon!");
          return;
        }
        ref.read(reminderNotifierProvider).updateRecurringInterval(interval);
        ref.read(bottomElementProvider).setAsNone();
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
