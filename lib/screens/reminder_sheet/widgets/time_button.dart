import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Note: Both dateTime and duration can't be null. And in case both are give, dateTime would be preferred.
class TimeButton extends ConsumerWidget {
  final DateTime? dateTime;
  final Duration? duration;
  final Alignment? curveCorner;

  TimeButton({super.key, this.dateTime, this.duration, this.curveCorner})
      : assert(dateTime != null || duration != null,
            "Both dateTime and duration can't be null");

  void editTime(Reminder rem) {
    rem.dateAndTime = rem.dateAndTime.add(duration!);
  }

  /// Sets the value of the dateTime attribute of the Reminder to the
  /// time specified in the String parameter.
  void setTime(Reminder rem) {
    DateTime updatedTime = DateTime(
      rem.dateAndTime.year,
      rem.dateAndTime.month,
      rem.dateAndTime.day,
      dateTime!.hour,
      dateTime!.minute,
    );

    rem.updatedTime(updatedTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder = ref.read(reminderNotifierProvider);
    final reminderNotifier = ref.read(reminderNotifierProvider.notifier);
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
          if (dateTime != null) {
            setTime(reminder);
          } else if (duration != null) {
            editTime(reminder);
          }
          reminderNotifier.updateReminder(reminder);
        },
        child: getChild(context));
  }

  Widget getChild(BuildContext context) {
    late String text;

    if (dateTime != null) {
      text = getFormattedTimeForTimeSetButton(dateTime!);
    } else if (duration != null) {
      text =
          getFormattedDurationForTimeEditButton(duration!, addPlusSymbol: true);
    } else {
      throw "Both dateTime and duration can't be null";
    }

    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodyMedium!
          .copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
    );
  }
}
