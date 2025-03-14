import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/models/no_rush_reminder/no_rush_reminder.dart';
import '../../../../core/data/models/reminder/reminder.dart';
import '../../../../core/extensions/datetime_ext.dart';
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
    if (reminder.isRecurring) {
      return RecurringReminderListTile(reminder: reminder);
    }
    return ReminderListTile(reminder: reminder);
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
                    reminder.dateTime.friendly(
                      is24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    reminder.dateTime.formattedDuration,
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
                    reminder.dateTime.friendly(
                      is24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
                    ),
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
                    Text(
                      '⟳ ${reminder.recurringInterval.name}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      reminder.dateTime.formattedDuration,
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
          ref
              .read(remindersNotifierProvider.notifier)
              .resumeReminder(reminder.id);
        } else {
          ref
              .read(remindersNotifierProvider.notifier)
              .pauseReminder(reminder.id);
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
          child: SizedBox(
            width: double.maxFinite,
            child: Text(
              reminder.title,
              style: Theme.of(context).textTheme.titleMedium,
              softWrap: true,
            ),
          ),
        ),
      ),
    );
  }
}
