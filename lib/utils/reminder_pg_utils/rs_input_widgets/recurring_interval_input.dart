import 'package:flutter/material.dart';
import 'package:Rem/pages/reminder_page.dart';
import 'package:Rem/reminder_class/reminder.dart';

class RS_RecurringIntervalInput extends StatelessWidget {
  final Reminder thisReminder;
  final Function(Reminder) save;
  final Function(FieldType) moveFocus;
  final fieldType = FieldType.Rec_Interval;

  const RS_RecurringIntervalInput({
    super.key,
    required this.thisReminder,
    required this.save,
    required this.moveFocus
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      mainAxisSpacing: 1,
      crossAxisSpacing: 1,
      crossAxisCount: 3,
      shrinkWrap: true,
      childAspectRatio: 1.5,
      children: [
        intervalEditButton(Duration(minutes: 1), context),
        intervalEditButton(Duration(minutes: 5), context),
        intervalEditButton(Duration(minutes: 10), context),
        intervalEditButton(Duration(minutes: 15), context),
        intervalEditButton(Duration(minutes: 30), context),
        intervalEditButton(Duration(hours: 1), context),
      ],
    );
  }

  Widget intervalEditButton(Duration duration, BuildContext context) {
    return SizedBox(
      height: 60,
      width: 150,
      child: ElevatedButton(
        onPressed: () {
          thisReminder.recurringInterval = duration;

          save(thisReminder);
          moveFocus(fieldType);
        }, 
        child: Text(
          "${duration.inMinutes} minutes",
          style: Theme.of(context).textTheme.bodyLarge,
        )
      ),
    );
  }
}