import 'package:Rem/consts/const_colors.dart';
import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/widgets/duration_picker.dart';
import 'package:Rem/widgets/save_close_buttons.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';

class DefaultAutoSnoozeDurationModal extends StatefulWidget {
  DefaultAutoSnoozeDurationModal({super.key});

  @override
  State<DefaultAutoSnoozeDurationModal> createState() =>
      _DefaultAutoSnoozeDurationModalState();
}

class _DefaultAutoSnoozeDurationModalState
    extends State<DefaultAutoSnoozeDurationModal> {
  Duration currentSelectedDuration =
      UserDB.getSetting(SettingOption.RepeatIntervalFieldValue);
  String durString = "";

  @override
  void initState() {
    refresh();
    super.initState();
  }

  void refresh() {
    setState(() {
      durString = "Every " +
          currentSelectedDuration.pretty(tersity: DurationTersity.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 450,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            Text("Default Auto Snooze Duration",
                style: Theme.of(context).textTheme.titleLarge),
            Divider(),
            SizedBox(height: 10),
            dateTimeWidget(),
            DurationPickerBase(onDurationChange: (dur) {
              currentSelectedDuration = dur;
              refresh();
            }),
            SaveCloseButtons(onTapSave: () {
              UserDB.setSetting(SettingOption.RepeatIntervalFieldValue,
                  currentSelectedDuration);
              Navigator.pop(context);
            })
          ],
        ));
  }

  Widget dateTimeWidget() {
    return Container(
        width: MediaQuery.sizeOf(context).width * 0.5,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: ConstColors.lightGreyLessOpacity),
        padding: EdgeInsets.all(10),
        child: Center(
            child: Text(durString,
                style: Theme.of(context).textTheme.titleMedium)));
  }
}
