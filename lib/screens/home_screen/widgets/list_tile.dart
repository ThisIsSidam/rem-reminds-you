import 'package:Rem/modals/no_rush_reminders/no_rush_reminders.dart';
import 'package:Rem/modals/recurring_reminder/recurring_reminder.dart';
import 'package:Rem/screens/reminder_sheet/reminder_sheet.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:flutter/material.dart';

import '../../../modals/recurring_interval/recurring_interval.dart';
import '../../../modals/reminder_modal/reminder_modal.dart';

class HomePageReminderEntryListTile extends StatelessWidget {
  final ReminderModal reminder;

  const HomePageReminderEntryListTile({
    super.key,
    required this.reminder,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return ReminderSheet(
                reminder: reminder,
              );
            });
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      reminder.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      softWrap: true,
                    ),
                  ),
                  if (reminder is RecurringReminderModal &&
                      (reminder as RecurringReminderModal).recurringInterval !=
                          RecurringInterval.none) ...<Widget>[
                    const SizedBox(width: 8), // Add some minimum spacing
                    Text(
                      "⟳ ${(reminder as RecurringReminderModal).recurringInterval.toString()}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              if (reminder is! NoRushRemindersModal)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (reminder is! NoRushRemindersModal)
                      Text(
                        getFormattedDateTime(reminder.dateTime),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    Text(
                      getFormattedDuration(reminder),
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
