import 'package:Rem/feature/reminder_screen/presentation/providers/sheet_reminder_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/enums/recurring_interval.dart';
import '../../providers/central_widget_provider.dart';

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
        crossAxisCount: 3,
        shrinkWrap: true,
        childAspectRatio: 1.5,
        children: [
          for (final RecurringInterval interval in RecurringInterval.values)
            intervalButton(interval, context, ref)
        ],
      ),
    );
  }

  Widget intervalButton(
      RecurringInterval interval, BuildContext context, WidgetRef ref) {
    final recurringInterval = ref.read(sheetReminderNotifier).recurringInterval;
    bool isPickedOption = interval == recurringInterval;

    return ElevatedButton(
      onPressed: () {
        ref.read(sheetReminderNotifier).updateRecurringInterval(interval);
        ref.read(centralWidgetNotifierProvider.notifier).reset();
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
