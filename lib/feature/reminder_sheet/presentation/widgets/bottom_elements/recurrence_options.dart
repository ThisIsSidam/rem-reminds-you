import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/data/models/recurring_interval/recurring_interval.dart';
import '../../providers/central_widget_provider.dart';
import '../../providers/sheet_reminder_notifier.dart';

class ReminderRecurrenceOptionsWidget extends ConsumerWidget {
  const ReminderRecurrenceOptionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: GridView.count(
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        crossAxisCount: 2,
        shrinkWrap: true,
        childAspectRatio: 2,
        children: <Widget>[
          // TODO : Implement proper semi weekly recurrence and add this back
          // for (final RecurringInterval interval in RecurringInterval.values)
          //   intervalButton(interval, context, ref),
          intervalButton(RecurringInterval.none, context, ref),
          intervalButton(RecurringInterval.daily, context, ref),
          intervalButton(RecurringInterval.weekly, context, ref),
          intervalButton(RecurringInterval.monthly, context, ref),
        ],
      ),
    );
  }

  Widget intervalButton(
    RecurringInterval interval,
    BuildContext context,
    WidgetRef ref,
  ) {
    final RecurringInterval recurringInterval =
        ref.read(sheetReminderNotifier).recurringInterval;
    final bool isPickedOption = interval == recurringInterval;

    return ElevatedButton(
      onPressed: () {
        ref.read(sheetReminderNotifier).updateRecurringInterval(interval);
        ref.read(centralWidgetNotifierProvider.notifier).reset();
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(4),
        shape: const BeveledRectangleBorder(),
        backgroundColor: isPickedOption
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Text(
        interval.toString(),
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: isPickedOption
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSecondaryContainer,
            ),
      ),
    );
  }
}
