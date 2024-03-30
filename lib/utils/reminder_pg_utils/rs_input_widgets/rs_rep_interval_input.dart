import 'package:flutter/material.dart';
import 'package:nagger/pages/reminder_page.dart';
import 'package:nagger/reminder_class/reminder.dart';

class RS_RepIntervalInput extends StatelessWidget {
  final Reminder thisReminder;
  final Function(Reminder) save;
  final Function(FieldType) moveFocus;
  final fieldType = FieldType.R_Interval;

  const RS_RepIntervalInput({
    super.key,
    required this.thisReminder,
    required this.save,
    required this.moveFocus
  });

  @override
  Widget build(BuildContext context) {
    debugPrint("Showing durationgButtonsGrid");
    return GridView.count(
      mainAxisSpacing: 1,
      crossAxisSpacing: 1,
      crossAxisCount: 3,
      shrinkWrap: true,
      childAspectRatio: 1.5,
      children: [
        intervalEditButton(Duration(minutes: 2), context),
        intervalEditButton(Duration(minutes: 5), context),
        intervalEditButton(Duration(minutes: 10), context),
        intervalEditButton(Duration(minutes: 15), context),
        intervalEditButton(Duration(minutes: 30), context),
        intervalEditButton(Duration(minutes: 45), context),
        intervalEditButton(Duration(hours: 1), context),
        intervalEditButton(Duration(hours: 2), context),
        intervalEditButton(Duration(hours: 3), context),
      ],
    );
  }

  Widget intervalEditButton(Duration duration, BuildContext context) {
    return SizedBox(
      height: 60,
      width: 150,
      child: ElevatedButton(
        onPressed: () {
          thisReminder.repetitionInterval = duration;

          save(thisReminder);
          moveFocus(fieldType);
        }, 
        child: Text(
          (duration.inMinutes < 60)
          ? "${duration.inMinutes.toString()} mn"
          : "${duration.inHours.toString()} hrs",
          style: Theme.of(context).textTheme.bodyLarge,
        )
      ),
    );
  }
}