import 'package:Rem/feature/reminder_screen/presentation/providers/sheet_reminder_notifier.dart';
import 'package:Rem/shared/utils/datetime_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimeSetButton extends ConsumerWidget {
  final DateTime dateTime;

  TimeSetButton({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.all(4)),
          backgroundColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.secondaryContainer,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(),
          ),
          splashFactory: InkSplash.splashFactory,
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.blue
                    .withOpacity(0.2); // Set your desired splash color
              }
              return null; // Use default overlay color otherwise
            },
          ),
        ),
        onPressed: () {
          final reminderTime = ref.read(sheetReminderNotifier).dateTime;

          DateTime updatedTime = DateTime(
            reminderTime.year,
            reminderTime.month,
            reminderTime.day,
            dateTime.hour,
            dateTime.minute,
          );

          ref.read(sheetReminderNotifier).updateDateTime(updatedTime);
        },
        child: getChild(context));
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
  final Duration duration;

  TimeEditButton({super.key, required this.duration});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.all(4)),
          backgroundColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.secondaryContainer,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(),
          ),
          splashFactory: InkSplash.splashFactory,
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.blue
                    .withOpacity(0.2); // Set your desired splash color
              }
              return null; // Use default overlay color otherwise
            },
          ),
        ),
        onPressed: () {
          final DateTime reminderTime =
              ref.read(sheetReminderNotifier).dateTime;
          ref
              .read(sheetReminderNotifier)
              .updateDateTime(reminderTime.add(duration));
        },
        child: getChild(context));
  }

  Widget getChild(BuildContext context) {
    String text =
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
