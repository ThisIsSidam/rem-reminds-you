import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:Rem/provider/settings_provider.dart';
import 'package:Rem/screens/reminder_sheet/providers/bottom_element_provider.dart';
import 'package:Rem/screens/reminder_sheet/widgets/base_versions/alert_dialog_base.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReminderSnoozeOptionsWidget extends ConsumerWidget {
  const ReminderSnoozeOptionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider.notifier);

    final List<Duration> repeatIntervalDurations = <Duration>[
      settings.autoSnoozeOption1,
      settings.autoSnoozeOption2,
      settings.autoSnoozeOption3,
      settings.autoSnoozeOption4,
      settings.autoSnoozeOption5,
      settings.autoSnoozeOption6,
    ];

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Auto-Snooze Options",
                style: Theme.of(context).textTheme.titleMedium),
          ),
          getButtonsGrid(context, repeatIntervalDurations, ref)
        ]);

    return AlertDialogBase(
      title: "Snooze options",
      tooltipMsg:
          "A reminder's notification are repeated at a certain interval until you mark the reminder as done.",
      content: SizedBox(
        height: 175,
        width: 375,
        child: getButtonsGrid(context, repeatIntervalDurations, ref),
      ),
    );
  }

  Widget getButtonsGrid(
      BuildContext context, List<Duration> intervalDurations, WidgetRef ref) {
    //TODO: Check if all the corners are round or not.
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: GridView.count(
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        crossAxisCount: 3,
        shrinkWrap: true,
        childAspectRatio: 1.5,
        children: [
          for (var dur in intervalDurations)
            intervalEditButton(dur, context, ref),
        ],
      ),
    );
  }

  Widget intervalEditButton(
      Duration duration, BuildContext context, WidgetRef ref) {
    final reminder = ref.read(reminderNotifierProvider);
    bool isPickedDuration = duration == reminder.notifRepeatInterval;
    return ElevatedButton(
      onPressed: () {
        reminder.notifRepeatInterval = duration;
        ref.read(reminderNotifierProvider.notifier).updateReminder(reminder);
        ref.read(bottomElementProvider).setAsNone();
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(4),
        surfaceTintColor: Colors.transparent,
        shape: BeveledRectangleBorder(),
        backgroundColor: isPickedDuration
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Text(
        getFormattedDurationForTimeEditButton(duration),
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: isPickedDuration
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSecondaryContainer),
      ),
    );
  }
}
