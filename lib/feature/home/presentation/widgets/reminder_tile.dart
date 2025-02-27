import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/models/no_rush_reminder/no_rush_reminder.dart';
import '../../../../core/data/models/recurring_interval/recurring_interval.dart';
import '../../../../core/data/models/reminder/recurring_reminder.dart';
import '../../../../core/data/models/reminder_model/reminder_model.dart';
import '../../../../shared/utils/datetime_methods.dart';
import '../../../reminder_sheet/presentation/sheet_helper.dart';
import '../providers/reminders_provider.dart';

class HomePageReminderEntryListTile extends StatelessWidget {
  const HomePageReminderEntryListTile({
    required this.reminder,
    super.key,
  });
  final ReminderModel reminder;

  @override
  Widget build(BuildContext context) {
    if (reminder is RecurringReminderModel) {
      final RecurringReminderModel recurringReminder =
          reminder as RecurringReminderModel;
      return RecurringReminderListTile(reminder: recurringReminder);
    } else if (reminder is NoRushReminderModel) {
      final NoRushReminderModel noRushReminder =
          reminder as NoRushReminderModel;
      return NoRushReminderListTile(reminder: noRushReminder);
    } else {
      return ReminderListTile(reminder: reminder);
    }
  }
}

class ReminderListTile extends ConsumerWidget {
  const ReminderListTile({
    required this.reminder,
    super.key,
  });
  final ReminderModel reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        SheetHelper().openReminderSheet(
          context,
          reminder: reminder,
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary.withValues(
                alpha: 0.10,
              ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.inversePrimary.withValues(
                  alpha: 0.25,
                ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                reminder.title,
                style: Theme.of(context).textTheme.titleMedium,
                softWrap: true,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
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
  const RecurringReminderListTile({
    required this.reminder,
    super.key,
  });
  final RecurringReminderModel reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        SheetHelper().openReminderSheet(
          context,
          reminder: reminder,
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary.withValues(
                alpha: 0.10,
              ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.inversePrimary.withValues(
                  alpha: 0.25,
                ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
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
                  children: <Widget>[
                    if (reminder.recurringInterval != RecurringInterval.isNone)
                      Text(
                        '⟳ ${reminder.recurringInterval}',
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
      child: Text(
        isPaused ? 'Resume' : 'Pause',
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

class NoRushReminderListTile extends ConsumerWidget {
  const NoRushReminderListTile({
    required this.reminder,
    super.key,
  });
  final NoRushReminderModel reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        SheetHelper().openReminderSheet(
          context,
          reminder: reminder,
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary.withValues(
                alpha: 0.10,
              ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.inversePrimary.withValues(
                  alpha: 0.25,
                ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
