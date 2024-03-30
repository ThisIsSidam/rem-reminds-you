import 'package:flutter/material.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/pages/reminder_page.dart';
import 'package:nagger/reminder_class/reminder.dart';
import 'package:nagger/utils/reminder_pg_utils/buttons/time_edit_button.dart';
import 'package:nagger/utils/reminder_pg_utils/buttons/time_set_button.dart';

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

    thisReminder.updatedTime(updatedTime);
    save(thisReminder);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.count(
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
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
              ElevatedButton(
                onPressed: () {
                  moveFocus(fieldType);
                }, 
                child: Text(
                  "Next",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  

}