import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/utils/datetime_methods.dart';
import '../providers/sheet_reminder_notifier.dart';

class TimeSetButton extends ConsumerWidget {
  const TimeSetButton({required this.dateTime, super.key});
  final DateTime dateTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ButtonStyle(
        padding: WidgetStateProperty.all(const EdgeInsets.all(4)),
        backgroundColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.secondaryContainer,
        ),
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(),
        ),
        splashFactory: InkSplash.splashFactory,
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.blue
                  .withValues(alpha: 0.2); // Set your desired splash color
            }
            return null; // Use default overlay color otherwise
          },
        ),
      ),
      onPressed: () {
        final DateTime reminderTime = ref.read(sheetReminderNotifier).dateTime;

        final DateTime updatedTime = DateTime(
          reminderTime.year,
          reminderTime.month,
          reminderTime.day,
          dateTime.hour,
          dateTime.minute,
        );
        ref.read(sheetReminderNotifier).cleanTitle();
        ref.read(sheetReminderNotifier).updateDateTime(updatedTime);
      },
      child: getChild(context),
    );
  }

  Widget getChild(BuildContext context) {
    late String text;
    text = getFormattedTimeForTimeSetButton(dateTime);

    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodyMedium!
          .copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
    );
  }
}

class TimeEditButton extends ConsumerWidget {
  const TimeEditButton({required this.duration, super.key});
  final Duration duration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ButtonStyle(
        padding: WidgetStateProperty.all(const EdgeInsets.all(4)),
        backgroundColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.secondaryContainer,
        ),
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(),
        ),
        splashFactory: InkSplash.splashFactory,
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.blue
                  .withValues(alpha: 0.2); // Set your desired splash color
            }
            return null; // Use default overlay color otherwise
          },
        ),
      ),
      onPressed: () {
        final DateTime reminderTime = ref.read(sheetReminderNotifier).dateTime;

        ref.read(sheetReminderNotifier).cleanTitle();
        ref
            .read(sheetReminderNotifier)
            .updateDateTime(reminderTime.add(duration));
      },
      child: getChild(context),
    );
  }

  Widget getChild(BuildContext context) {
    final String text =
        getFormattedDurationForTimeEditButton(duration, addPlusSymbol: true);

    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodyMedium!
          .copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
    );
  }
}
