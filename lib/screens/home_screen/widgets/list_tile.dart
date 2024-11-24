import 'package:Rem/modals/no_rush_reminders/no_rush_reminders.dart';
import 'package:Rem/screens/reminder_sheet/reminder_sheet.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:flutter/material.dart';

import '../../../modals/reminder_modal/reminder_modal.dart';

class HomePageReminderEntryListTile extends StatelessWidget {
  final ReminderModal reminder;

  const HomePageReminderEntryListTile({
    super.key,
    required this.reminder,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        reminder.title,
        style: Theme.of(context).textTheme.titleMedium,
        softWrap: true,
      ),
      dense: true,
      subtitle: reminder is NoRushRemindersModal
          ? null
          : Text(getFormattedDateTime(reminder.dateTime),
              style: Theme.of(context).textTheme.bodyMedium),
      trailing: reminder is NoRushRemindersModal
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // if (reminder is RecurringReminderModal && reminder.recurringInterval != RecurringInterval.none)
                //   Text(
                //     "⟳ ${reminder.recurringInterval.name}",
                //     style: Theme.of(context).textTheme.bodySmall,
                //   ),
                Text(
                  getFormattedDuration(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
      tileColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      minVerticalPadding: 8,
      minTileHeight: 60,
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
    );
  }

  String getFormattedDuration() {
    if (reminder.dateTime.isBefore(DateTime.now())) {
      return '${getPrettyDurationFromDateTime(reminder.dateTime)} ago'
          .replaceFirst('-', '');
    } else {
      return 'in ${getPrettyDurationFromDateTime(reminder.dateTime)}';
    }
  }
}
