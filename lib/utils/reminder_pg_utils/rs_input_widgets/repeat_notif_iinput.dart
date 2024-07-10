import 'package:flutter/material.dart';
import 'package:Rem/pages/reminder_page.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/other_utils/snack_bar.dart';

class RS_RepeatNotifInput extends StatelessWidget {
  final Reminder thisReminder;
  final Function(Reminder) save;
  final Function(FieldType) moveFocus;
  final fieldType = FieldType.Repeat;

  const RS_RepeatNotifInput({
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
        intervalButton(context, RepeatInterval.none),
        intervalButton(context, RepeatInterval.daily),
        intervalButton(context, RepeatInterval.weekly),
        intervalButton(context, RepeatInterval.custom),
      ],
    );
  }

  Widget intervalButton(context, RepeatInterval interval) {
    return SizedBox(
      height: 75,
      width: 150,
      child: ElevatedButton(
        onPressed: () {

          if (interval == RepeatInterval.custom)
          {
            showSnackBar(context, "Coming soon!");
            return;
          }

          thisReminder.repeatInterval = interval;

          save(thisReminder);
          moveFocus(fieldType);
        }, 
        child: Text(
          RepeatIntervalExtension.getDisplayName(interval),
        ),
      ),
    );
  }
}