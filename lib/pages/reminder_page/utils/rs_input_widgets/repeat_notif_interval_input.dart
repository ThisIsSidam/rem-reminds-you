import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:flutter/material.dart';
import 'package:Rem/pages/reminder_page/reminder_page.dart';
import 'package:Rem/reminder_class/reminder.dart';

class RS_NotifRepeatIntervalInput extends StatelessWidget {
  final Reminder thisReminder;
  final Function(Reminder) save;
  final Function(FieldType) moveFocus;
  final fieldType = FieldType.Rec_Interval;

  RS_NotifRepeatIntervalInput({
    super.key,
    required this.thisReminder,
    required this.save,
    required this.moveFocus
  });

  final List<Duration> repeatIntervalDurations = List.generate(6, (index) {
    final dur = UserDB.getSetting(SettingsOptionMethods.fromInt(index + 15));;
    if (!(dur is Duration)) 
    {
      print("[repeatIntervals] Duration not received | $dur");
    }
    return dur;
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
        for (var dur in repeatIntervalDurations)
          intervalEditButton(dur, context),
      ],
    );
  }

  Widget intervalEditButton(Duration duration, BuildContext context) {
    return SizedBox(
      height: 60,
      width: 150,
      child: ElevatedButton(
        onPressed: () {
          thisReminder.notifRepeatInterval = duration;

          save(thisReminder);
          moveFocus(fieldType);
        }, 
        child: Text(
          "${duration.inMinutes} minute${duration.inMinutes == 1 ? "" : "s"}",
          style: Theme.of(context).textTheme.bodyLarge,
        )
      ),
    );
  }
}