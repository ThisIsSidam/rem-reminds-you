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
    FocusManager.instance.primaryFocus?.unfocus();
    debugPrint("Showing durationgButtonsGrid");
    return FractionallySizedBox(
      heightFactor: 0.45,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: GridView.count(
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          crossAxisCount: 3,
          shrinkWrap: true,
          childAspectRatio: 1.5,
          children: [
            intervalEditButton(Duration(minutes: 2)),
            intervalEditButton(Duration(minutes: 5)),
            intervalEditButton(Duration(minutes: 10)),
            intervalEditButton(Duration(minutes: 15)),
            intervalEditButton(Duration(minutes: 30)),
            intervalEditButton(Duration(minutes: 45)),
            intervalEditButton(Duration(hours: 1)),
            intervalEditButton(Duration(hours: 2)),
            intervalEditButton(Duration(hours: 3)),
          ],
        ),
      ),
    );
  }

  Widget intervalEditButton(Duration duration) {
    return SizedBox(
      height: 75,
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
          : "${duration.inHours.toString()} hrs"
        )
      ),
    );
  }
}