import 'package:Rem/core/models/no_rush_reminders/no_rush_reminders.dart';
import 'package:Rem/core/models/recurring_interval/recurring_interval.dart';
import 'package:Rem/core/models/recurring_reminder/recurring_reminder.dart';
import 'package:Rem/feature/home/presentation/providers/reminders_provider.dart';
import 'package:Rem/feature/reminder_sheet/presentation/helper/reminder_sheet_helper.dart';
import 'package:Rem/shared/utils/datetime_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/reminder_model/reminder_model.dart';

class HomePageReminderEntryListTile extends StatelessWidget {
  final ReminderModel reminder;

  const HomePageReminderEntryListTile({
    super.key,
    required this.reminder,
  });

  Widget build(BuildContext context) {
    if (reminder is RecurringReminderModel) {
      final recurringReminder = reminder as RecurringReminderModel;
      return RecurringReminderListTile(reminder: recurringReminder);
    } else if (reminder is NoRushRemindersModel) {
      final noRushReminder = reminder as NoRushRemindersModel;
      return NoRushReminderListTile(reminder: noRushReminder);
    } else {
      return ReminderListTile(reminder: reminder);
    }
  }
}

class ReminderListTile extends ConsumerWidget {
  final ReminderModel reminder;

  const ReminderListTile({
    super.key,
    required this.reminder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ReminderSheetHelper.openSheet(
          context: context,
          ref: ref,
          reminder: reminder,
        );
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reminder.title,
                style: Theme.of(context).textTheme.titleMedium,
                softWrap: true,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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

class RecurringReminderListTile extends ConsumerWidget {
  final RecurringReminderModel reminder;

  const RecurringReminderListTile({
    super.key,
    required this.reminder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ReminderSheetHelper.openSheet(
          context: context,
          ref: ref,
          reminder: reminder,
        );
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    reminder.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    softWrap: true,
                  ),
                  Text(
                    getFormattedDateTime(reminder.dateTime),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              if (reminder.paused)
                _buildResumeButton(context, ref, reminder.paused)
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if ((reminder).recurringInterval != RecurringInterval.none)
                      Text(
                        "⟳ ${(reminder).recurringInterval.toString()}",
                        style: Theme.of(context).textTheme.bodySmall,
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

  OutlinedButton _buildResumeButton(
    BuildContext context,
    WidgetRef ref,
    bool isPaused,
  ) {
    return OutlinedButton(
      onPressed: () {
        if (isPaused) {
          ref.read(remindersProvider.notifier).resumeReminder(reminder.id);
        } else {
          ref.read(remindersProvider.notifier).pauseReminder(reminder.id);
        }
      },
      child: Text(
        isPaused ? 'Resume' : 'Pause',
        style: Theme.of(context).textTheme.labelMedium,
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor:
            Theme.of(context).colorScheme.inversePrimary.withAlpha(100),
        side: BorderSide(
          color: Theme.of(context).colorScheme.inversePrimary..withAlpha(100),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class NoRushReminderListTile extends ConsumerWidget {
  final NoRushRemindersModel reminder;

  const NoRushReminderListTile({
    super.key,
    required this.reminder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ReminderSheetHelper.openSheet(
          context: context,
          ref: ref,
          reminder: reminder,
        );
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
              Text(
                reminder.title,
                style: Theme.of(context).textTheme.titleMedium,
                softWrap: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
