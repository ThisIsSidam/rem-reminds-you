import 'package:flutter/material.dart';
import 'package:Rem/pages/reminder_page/reminder_page.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/other_utils/snack_bar.dart';

class RS_RecurringIntervalInput extends StatelessWidget {
  final Reminder thisReminder;
  final Function(Reminder) save;
  final Function(FieldType) moveFocus;
  final fieldType = FieldType.Repeat;

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
      crossAxisCount: 4,
      shrinkWrap: true,
      childAspectRatio: 1.5,
      children: [
        intervalButton(context, RecurringInterval.none),
        intervalButton(context, RecurringInterval.daily),
        intervalButton(context, RecurringInterval.weekly),
        intervalButton(context, RecurringInterval.custom),
      ],
    );
  }

  Widget intervalButton(context, RecurringInterval interval) {
    return SizedBox(
      height: 75,
      width: 150,
      child: ElevatedButton(
        onPressed: () {

          if (interval == RecurringInterval.custom)
          {
            showSnackBar(context, "Coming soon!");
            return;
          }

          thisReminder.recurringInterval = interval;

          save(thisReminder);
          moveFocus(fieldType);
        }, 
        child: Text(
          RecurringIntervalExtension.getDisplayName(interval),
        ),
      ),
    );
  }
}