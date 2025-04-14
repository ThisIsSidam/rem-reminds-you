import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/extensions/duration_ext.dart';
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

        DateTime updatedTime = DateTime(
          reminderTime.year,
          reminderTime.month,
          reminderTime.day,
          dateTime.hour,
          dateTime.minute,
        );
        if (updatedTime.isBefore(DateTime.now())) {
          updatedTime = updatedTime.add(const Duration(days: 1));
        }
        ref.read(sheetReminderNotifier).cleanTitle();
        ref.read(sheetReminderNotifier).updateDateTime(updatedTime);
      },
      child: getChild(context, ref),
    );
  }

  Widget getChild(BuildContext context, WidgetRef ref) {
    late String text;
    text = dateTime.formattedHM(
      is24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
    );

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
    final DateTime reminderTime = ref.watch(sheetReminderNotifier).dateTime;
    final bool isEnabled = reminderTime.add(duration).isAfter(DateTime.now());
    return ElevatedButton(
      style: ButtonStyle(
        padding: WidgetStateProperty.all(const EdgeInsets.all(4)),
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withAlpha(100);
            }
            return Theme.of(context).colorScheme.secondaryContainer;
          },
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
      onPressed: isEnabled
          ? () {
              final DateTime reminderTime =
                  ref.read(sheetReminderNotifier).dateTime;

              ref.read(sheetReminderNotifier).cleanTitle();
              ref
                  .read(sheetReminderNotifier)
                  .updateDateTime(reminderTime.add(duration));
            }
          : null,
      child: getChild(context),
    );
  }

  Widget getChild(BuildContext context) {
    final String text = duration.friendly(addPlusSymbol: true);

    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodyMedium!
          .copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
    );
  }
}
