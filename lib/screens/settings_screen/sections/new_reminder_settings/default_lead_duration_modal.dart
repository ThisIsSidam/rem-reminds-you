import 'package:Rem/consts/const_colors.dart';
import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:Rem/widgets/duration_picker.dart';
import 'package:Rem/widgets/save_close_buttons.dart';
import 'package:flutter/material.dart';

class DefaultLeadDurationModal extends StatefulWidget {
  DefaultLeadDurationModal({super.key});

  @override
  State<DefaultLeadDurationModal> createState() =>
      _DefaultLeadDurationModalState();
}

class _DefaultLeadDurationModalState extends State<DefaultLeadDurationModal> {
  DateTime dateTime = DateTime.now();
  Duration currentSelectedDuration =
      UserDB.getSetting(SettingOption.DueDateAddDuration);
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
      diffString = 'in ${getPrettyDurationFromDateTime(dateTime)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 450,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            Text("Default Lead Duration",
                style: Theme.of(context).textTheme.titleLarge),
            Divider(),
            SizedBox(height: 10),
            dateTimeWidget(),
            DurationPickerBase(onDurationChange: (dur) {
              currentSelectedDuration = dur;
              refresh();
            }),
            SaveCloseButtons(onTapSave: () {
              UserDB.setSetting(
                  SettingOption.DueDateAddDuration, currentSelectedDuration);
              Navigator.pop(context);
            })
          ],
        ));
  }

  Widget dateTimeWidget() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: ConstColors.lightGreyLessOpacity,
        ),
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dateTimeString,
                style: Theme.of(context).textTheme.titleMedium),
            Text(diffString,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: Colors.white, fontSize: 12))
          ],
        ));
  }
}
