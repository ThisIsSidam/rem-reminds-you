import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/pages/reminder_page.dart';
import 'package:nagger/reminder_class/reminder.dart';
import 'package:nagger/utils/reminder_section_fields/time_buttons/time_edit_button.dart';
import 'package:nagger/utils/reminder_section_fields/time_buttons/time_set_button.dart';

class RS_DatetimeInput extends StatelessWidget {
  final Reminder thisReminder;
  final Function(Reminder) save;
  final Function(FieldType) moveFocus;
  final fieldType = FieldType.Time;

  const RS_DatetimeInput({
    super.key,
    required this.thisReminder,
    required this.save,
    required this.moveFocus
  });

  void editTime(Duration duration,) {
    thisReminder.dateAndTime = thisReminder
      .dateAndTime.add(duration);      
    save(thisReminder);
  }

  /// Sets the value of the dateTime attribute of the Reminder to the
  /// time specified in the String parameter.
  void setTime(String time) {
    final strParts = time.split(" ");

    final timeParts = strParts[0].split(":");
    var hour = int.parse(timeParts[0]);
    var minutes = int.parse(timeParts[1]);

    if (strParts[1] == "PM") {
      if (hour != 12) {
        hour += 12;
      }
    }

    DateTime updatedTime = DateTime(
      thisReminder.dateAndTime.year,
      thisReminder.dateAndTime.month,
      thisReminder.dateAndTime.day,
      hour,
      minutes,
    );

    debugPrint("Updated Time 1 : $updatedTime");

    if (updatedTime.isBefore(DateTime.now()))
    {
      updatedTime = updatedTime.add(Duration(days: 1));
      debugPrint("Updated Time 2 : $updatedTime");
    }

    thisReminder.dateAndTime = updatedTime;
    save(thisReminder);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("[mediaQuery] ${MediaQuery.of(context).viewInsets.bottom}");
    return FractionallySizedBox(
      heightFactor: 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10, 
          vertical: 10
        ),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                crossAxisCount: 4,
                shrinkWrap: true,
                childAspectRatio: 1.5,
                children: [
                  TimeSetButton(time: timeSetButton0930AM, setTime: setTime,),
                  TimeSetButton(time: timeSetButton12PM, setTime: setTime,),
                  TimeSetButton(time: timeSetButton0630PM, setTime: setTime,),
                  TimeSetButton(time: timeSetButton10PM, setTime: setTime,),
                  // Durations of some are altered to quickly get notifications. Will change later on.
                  TimeEditButton(editDuration: const Duration(seconds: 5), editTime: editTime,),
                  TimeEditButton(editDuration: const Duration(minutes: 1), editTime: editTime,),
                  TimeEditButton(editDuration: const Duration(hours: 3), editTime: editTime,),
                  TimeEditButton(editDuration: const Duration(days: 1), editTime: editTime,),
                  TimeEditButton(editDuration: const Duration(seconds: -5), editTime: editTime,),
                  TimeEditButton(editDuration: const Duration(minutes: -1), editTime: editTime,),
                  TimeEditButton(editDuration: const Duration(hours: -3), editTime: editTime,),
                  TimeEditButton(editDuration: const Duration(days: -1), editTime: editTime,),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                moveFocus(fieldType);
              }, 
              child: Text(
                "Set",
              )
            )
          ],
        ),
      ),
    );
  }
}