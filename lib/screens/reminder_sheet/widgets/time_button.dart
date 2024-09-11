import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Note: Both dateTime and duration can't be null. And in case both are give, dateTime would be preferred.
class TimeButton extends ConsumerWidget {
  final DateTime? dateTime;
  final Duration? duration;

  TimeButton({
    super.key,
    this.dateTime,
    this.duration,
  }) : assert(dateTime != null || duration != null, "Both dateTime and duration can't be null");

  void editTime(Reminder rem) {
    rem.dateAndTime = rem
      .dateAndTime.add(duration!);      
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
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(4),
      ),
      onPressed: () {
        if (dateTime != null) {
          setTime(reminder);
        } else if (duration != null) {
          editTime(reminder);
        }
        reminderNotifier.updateReminder(reminder);
      },
      child: getChild(context)
    );
  }

  Widget getChild(BuildContext context) {
    if (dateTime != null) {
      return Text(
        getFormattedTimeForTimeSetButton(dateTime!),
        style: Theme.of(context).textTheme.bodyMedium,
      );
    } else if
     (duration != null) {
      return Text(
        getFormattedDurationForTimeEditButton(duration!, addPlusSymbol: true),
        style: Theme.of(context).textTheme.bodyMedium,
      );
    } else {
      throw "Both dateTime and duration can't be null";
    }
  }
}