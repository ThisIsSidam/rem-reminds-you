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
        childAspectRatio: 2.5,
        children: <Widget>[
          IntervalButton(interval: RecurringInterval()),
          IntervalButton(interval: RecurringInterval.daily()),
          IntervalButton(interval: RecurringInterval.weekly()),
          IntervalButton(interval: RecurringInterval.monthly()),
        ],
      ),
    );
  }
}

class IntervalButton extends ConsumerWidget {
  const IntervalButton({required this.interval, super.key});

  final RecurringInterval interval;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        interval.name,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: isPickedOption
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSecondaryContainer,
            ),
      ),
    );
  }
}
