import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/utils/flex_picker/flex_duration_picker.dart';
import 'package:Rem/utils/functions/datetime_methods.dart';
import 'package:Rem/utils/other_utils/save_close_buttons.dart';
import 'package:flutter/material.dart';

class DefaultDueDatetimeModal extends StatefulWidget {

  DefaultDueDatetimeModal({
    super.key
  });

  @override
  State<DefaultDueDatetimeModal> createState() => _DefaultDueDatetimeModalState();
}

class _DefaultDueDatetimeModalState extends State<DefaultDueDatetimeModal> {
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
      diffString = getFormattedDiffString(dateTime: dateTime);
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
          SizedBox(height: 10),
          dateTimeWidget(),
          durationPickerWidget(),
          SaveCloseButtons(onTapSave: () {
            UserDB.setSetting(SettingOption.DueDateAddDuration, currentSelectedDuration);
            Navigator.pop(context);
          })
          
        ],
      )
    );
  }

  Widget durationPickerWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FlexDurationPicker(
        // initialDuration: currentSelectedDuration,
        mode: FlexDurationPickerMode.hm,
        onDurationChanged: (dur) {
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