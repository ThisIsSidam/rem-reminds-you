import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/utils/other_utils/datetime_methods.dart';
import 'package:Rem/utils/reminder_pg_utils/buttons/save_close_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DefaultDueDatetime extends StatefulWidget {

  DefaultDueDatetime({
    super.key
  });

  @override
  State<DefaultDueDatetime> createState() => _DefaultDueDatetimeState();
}

class _DefaultDueDatetimeState extends State<DefaultDueDatetime> {
  DateTime dateTime = DateTime.now();
  Duration currentSelectedDuration = UserDB.getSetting(SettingOption.DueDateAddDuration);
  String dateTimeString = "";
  String diffString = "";

  @override
  void initState() {
    refresh();
    super.initState();
  }

  void refresh() {
    setState(() {
      dateTime = DateTime.now().add(currentSelectedDuration);
      dateTimeString = getFormattedDateTime(dateTime);
      diffString = getFormattedDiffString(dateTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          Text("Default Due Datetime", style: Theme.of(context).textTheme.titleLarge),
          Divider(),
          dateTimeWidget(),
          durationPickerWidget(),
          SaveCloseButtons(saveButton: () {
            UserDB.setSetting(SettingOption.DueDateAddDuration, currentSelectedDuration);
            Navigator.pop(context);
          })
          
        ],
      )
    );
  }

  Widget durationPickerWidget() {
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Brightness.dark
      ),
      child: CupertinoTimerPicker(
          mode: CupertinoTimerPickerMode.hm,
          initialTimerDuration: currentSelectedDuration,
          onTimerDurationChanged: (dur) {
            currentSelectedDuration = dur;
            refresh();
          }
        ),
    );
  }

  Widget dateTimeWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.white
        )
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dateTimeString,
          ),
          Text(
            diffString
          )
        ],
      )
    );
  }
}