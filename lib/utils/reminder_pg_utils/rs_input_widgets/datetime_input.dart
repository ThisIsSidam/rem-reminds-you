import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:flutter/material.dart';
import 'package:Rem/pages/reminder_page.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/reminder_pg_utils/buttons/time_edit_button.dart';
import 'package:Rem/utils/reminder_pg_utils/buttons/time_set_button.dart';

class RS_DatetimeInput extends StatelessWidget {
  final Reminder thisReminder;
  final Function(Reminder) save;
  final Function(FieldType) moveFocus;
  final fieldType = FieldType.Time;
  
  RS_DatetimeInput({
    super.key,
    required this.thisReminder,
    required this.save,
    required this.moveFocus
  });

  final List<DateTime> setDateTimes = List.generate(4, (index) {
    final dt = UserDB.getSetting(SettingsOptionMethods.fromInt(index+3));
    if (!(dt is DateTime))
    {
      throw "[setDateTimes] DateTime not received | $dt";
    } 
    return dt;
  }, growable: false);

  final List<Duration>  editDurations = List.generate(8, (index) {
    final dur = UserDB.getSetting(SettingsOptionMethods.fromInt(index+7));
    if  (!(dur is Duration)) 
    {
      throw "[editDurations] Duration not received | $dur";
    }
    return dur; 
  }, growable: false);

  void editTime(Duration duration,) {
    thisReminder.dateAndTime = thisReminder
      .dateAndTime.add(duration);      
    save(thisReminder);
  }

  /// Sets the value of the dateTime attribute of the Reminder to the
  /// time specified in the String parameter.
  void setTime(DateTime time) {
    DateTime updatedTime = DateTime(
      thisReminder.dateAndTime.year,
      thisReminder.dateAndTime.month,
      thisReminder.dateAndTime.day,
      time.hour,
      time.minute,
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
              TimeSetButton(time: setDateTimes[0], setTime: setTime,),
              TimeSetButton(time: setDateTimes[1], setTime: setTime,),
              TimeSetButton(time: setDateTimes[2], setTime: setTime,),
              TimeSetButton(time: setDateTimes[3], setTime: setTime,),
              TimeEditButton(editDuration: editDurations[0], editTime: editTime,),
              TimeEditButton(editDuration: editDurations[1], editTime: editTime,),
              TimeEditButton(editDuration: editDurations[2], editTime: editTime,),
              TimeEditButton(editDuration: editDurations[3], editTime: editTime,),
              TimeEditButton(editDuration: editDurations[4], editTime: editTime,),
              TimeEditButton(editDuration: editDurations[5], editTime: editTime,),
              TimeEditButton(editDuration: editDurations[6], editTime: editTime,),
              TimeEditButton(editDuration: editDurations[7], editTime: editTime,),
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