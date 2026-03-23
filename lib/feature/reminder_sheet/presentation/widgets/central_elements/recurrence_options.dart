import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/data/models/recurrence_rule.dart';
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
          IntervalButton(interval: RecurrenceRule()),
          IntervalButton(interval: RecurrenceRule.daily()),
          IntervalButton(interval: RecurrenceRule.weekly()),
          IntervalButton(interval: RecurrenceRule.monthly()),
        ],
      ),
    );
  }
}

class IntervalButton extends ConsumerWidget {
  const IntervalButton({required this.interval, super.key});

  final RecurrenceRule interval;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final RecurrenceRule recurrenceRule = ref
        .read(sheetReminderNotifier)
        .recurrenceRule;
    final bool isPickedOption = interval == recurrenceRule;

    return ElevatedButton(
      onPressed: () {
        ref.read(sheetReminderNotifier).updateRecurrenceRule(interval);
        ref.read(centralWidgetProvider.notifier).reset();
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
