import 'package:Rem/core/models/no_rush_reminder/no_rush_reminders_model.dart';
import 'package:Rem/core/models/recurring_reminder/recurring_reminder_model.dart';
import 'package:Rem/feature/home/presentation/providers/reminders_provider.dart';
import 'package:Rem/feature/reminder_screen/presentation/screens/reminder_screen.dart';
import 'package:Rem/shared/utils/datetime_methods.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/enums/recurring_interval.dart';
import '../../../../core/models/basic_reminder_model.dart';

class HomePageReminderEntryListTile extends HookConsumerWidget {
  final BasicReminderModel reminder;

  const HomePageReminderEntryListTile({
    super.key,
    required this.reminder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isRecurring = reminder is RecurringReminderModel &&
        (reminder as RecurringReminderModel).recurringInterval !=
            RecurringInterval.none;
    final bool isPaused =
        isRecurring && (reminder as RecurringReminderModel).paused;

    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReminderScreen(reminder: reminder),
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: (isPaused
                  ? colorScheme.surfaceContainerHigh
                  : colorScheme.inversePrimary)
              .withAlpha(100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.inversePrimary..withAlpha(100),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                        children: [
                          TextSpan(
                            text: reminder.title,
                          ),
                          if (isRecurring)
                            TextSpan(
                              text:
                                  "  ⟳ ${(reminder as RecurringReminderModel).recurringInterval.toString()}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                      softWrap: true,
                    ),
                    if (reminder is! NoRushRemindersModel)
                      Text(
                        getFormattedDateTime(reminder.dateTime),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
              if (isRecurring) _buildPauseButton(context, ref, isPaused),
            ],
          ),
        ),
      ),
    );
  }

  OutlinedButton _buildPauseButton(
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
