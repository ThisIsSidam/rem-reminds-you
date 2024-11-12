import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/reminder_sheet/reminder_sheet.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:flutter/material.dart';

class HomePageReminderEntryListTile extends StatelessWidget {
  final Reminder reminder;

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
      subtitle: Text(getFormattedDateTime(reminder.dateAndTime),
          style: Theme.of(context).textTheme.bodyMedium),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (reminder.recurringInterval != RecurringInterval.none)
            Text(
              "⟳ ${reminder.recurringInterval.name}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
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
                thisReminder: reminder,
              );
            });
      },
    );
  }

  String getFormattedDuration() {
    if (reminder.dateAndTime.isBefore(DateTime.now())) {
      return '${getPrettyDurationFromDateTime(reminder.dateAndTime)} ago'
          .replaceFirst('-', '');
    } else {
      return 'in ${getPrettyDurationFromDateTime(reminder.dateAndTime)}';
    }
  }
}
