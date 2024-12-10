import 'package:Rem/models/no_rush_reminders/no_rush_reminders.dart';
import 'package:Rem/models/recurring_reminder/recurring_reminder.dart';
import 'package:Rem/screens/reminder_sheet/reminder_sheet.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:flutter/material.dart';

import '../../../models/recurring_interval/recurring_interval.dart';
import '../../../models/reminder_model/reminder_model.dart';

class HomePageReminderEntryListTile extends StatelessWidget {
  final ReminderModel reminder;

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
                  if (reminder is RecurringReminderModel &&
                      (reminder as RecurringReminderModel).recurringInterval !=
                          RecurringInterval.none) ...<Widget>[
                    const SizedBox(width: 8), // Add some minimum spacing
                    Text(
                      "⟳ ${(reminder as RecurringReminderModel).recurringInterval.toString()}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              if (reminder is! NoRushRemindersModel)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (reminder is! NoRushRemindersModel)
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
