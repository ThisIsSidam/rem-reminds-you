import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/utils/other_utils/duration_picker.dart';
import 'package:Rem/utils/functions/datetime_methods.dart';
import 'package:Rem/utils/other_utils/save_close_buttons.dart';
import 'package:flutter/material.dart';

class DefaultRepeatIntervalModal extends StatefulWidget {

  DefaultRepeatIntervalModal({
    super.key
  });

  @override
  State<DefaultRepeatIntervalModal> createState() => _DefaultRepeatIntervalModalState();
}

class _DefaultRepeatIntervalModalState extends State<DefaultRepeatIntervalModal> {
  Duration currentSelectedDuration = UserDB.getSetting(SettingOption.RepeatIntervalFieldValue);
  String durString = "";


  @override
  void initState() {
    refresh();
    super.initState();
  }

  void refresh() {
    setState(() {
      durString = "Every " + formatDuration(currentSelectedDuration);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          Text("Default Repeat Interval", style: Theme.of(context).textTheme.titleLarge),
          Divider(),
          SizedBox(height: 10),
          dateTimeWidget(),
          DurationPickerBase(
            onDurationChange: (dur) {
              currentSelectedDuration = dur;
              refresh();
            }
          ),
          SaveCloseButtons(onTapSave: () {
            UserDB.setSetting(SettingOption.RepeatIntervalFieldValue, currentSelectedDuration);
            Navigator.pop(context);
          })
          
        ],
      )
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
      child: Text(durString)
    );
  }
}