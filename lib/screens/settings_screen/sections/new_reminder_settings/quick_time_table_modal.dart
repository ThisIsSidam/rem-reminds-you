import 'package:Rem/consts/const_colors.dart';
import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:Rem/widgets/grid_duration_picker.dart';
import 'package:Rem/widgets/save_close_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuickTimeTableModal extends StatefulWidget {

  QuickTimeTableModal({
    super.key
  });

  @override
  State<QuickTimeTableModal> createState() => _QuickTimeTableModalState();
}

class _QuickTimeTableModalState extends State<QuickTimeTableModal> {
  DateTime currentValueFromTimePicker = UserDB.getSetting(SettingOption.QuickTimeSetOption1);
  Duration currentValueFromDurationPicker = UserDB.getSetting(SettingOption.QuickTimeEditOption1);
  SettingOption selectedSettingOption = SettingOption.QuickTimeSetOption1;
  final isNegativeDurationScrollController = FixedExtentScrollController();

  bool showDurationWarning = false;

  Map<SettingOption, DateTime> setDateTimes = {
    for (int i = 3; i <= 6; i++) // Starting and Ending indexes of SetOptions in enum
      SettingsOptionMethods.fromInt(i): UserDB.getSetting(SettingsOptionMethods.fromInt(i))
  };

  final Map<SettingOption, Duration>  editDurations = {
    for (int i = 7; i <= 14; i++) // Starting and Ending indexes of editOptions in enum
      SettingsOptionMethods.fromInt(i): UserDB.getSetting(SettingsOptionMethods.fromInt(i))
  };

  @override
  void initState() {
    refresh();
    super.initState();
  }

  void refresh() {
    setState(() {});
  }

  void setSelectedOption(SettingOption option) {
    setState(() {
      selectedSettingOption = option;

      switch (selectedSettingOption) {
        case SettingOption.QuickTimeSetOption1:
        case SettingOption.QuickTimeSetOption2:
        case SettingOption.QuickTimeSetOption3:
        case SettingOption.QuickTimeSetOption4:
          currentValueFromTimePicker = setDateTimes[selectedSettingOption]!;
          break;
        case SettingOption.QuickTimeEditOption1:
        case SettingOption.QuickTimeEditOption2:
        case SettingOption.QuickTimeEditOption3:
        case SettingOption.QuickTimeEditOption4:
        case SettingOption.QuickTimeEditOption5:
        case SettingOption.QuickTimeEditOption6:
        case SettingOption.QuickTimeEditOption7:
        case SettingOption.QuickTimeEditOption8:
          currentValueFromDurationPicker = editDurations[selectedSettingOption]!;
          updatePickerPositionsOnButtonChange();
          break;
        default:
          break;
      }
    });
  }

  void updatePickerPositionsOnButtonChange() {
    if (currentValueFromDurationPicker.isNegative) {
      isNegativeDurationScrollController.jumpToItem(1);
    } else {
      isNegativeDurationScrollController.jumpToItem(0);
    }
  }

  void onSave() {
    setDateTimes.forEach((option, dt) {
      UserDB.setSetting(option, dt);
    });
    editDurations.forEach((option, dur) {
      UserDB.setSetting(option, dur);
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          Text("Default Due Datetime", style: Theme.of(context).textTheme.titleLarge),
          Divider(),
          SizedBox(height: 10),
          buttonsWidget(),
          getEditWidget(),
          SaveCloseButtons(
            onTapSave: onSave
          )
        ],
      )
    );
  }

  Widget getEditWidget() {
    switch (selectedSettingOption) {
      case SettingOption.QuickTimeSetOption1:
      case SettingOption.QuickTimeSetOption2:
      case SettingOption.QuickTimeSetOption3:
      case SettingOption.QuickTimeSetOption4:
        return dateTimePickerWidget();
      case SettingOption.QuickTimeEditOption1:
      case SettingOption.QuickTimeEditOption2:
      case SettingOption.QuickTimeEditOption3:
      case SettingOption.QuickTimeEditOption4:
      case SettingOption.QuickTimeEditOption5:
      case SettingOption.QuickTimeEditOption6:
      case SettingOption.QuickTimeEditOption7:
      case SettingOption.QuickTimeEditOption8:
        return CustomDurationPicker(
          allowNegative: true,
          onDurationChanged: (dur) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  editDurations[selectedSettingOption] = dur;
                });
              }
            });
          },
        );
      default:
        return SizedBox(height: 10, child: Placeholder());
    }
  }

  Widget dateTimePickerWidget() {
    return Container(
      width: 400,
      height: 200,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Brightness.dark
        ),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          onDateTimeChanged: (dt) {
            setState(() {
              setDateTimes[selectedSettingOption] = dt;
            });
          }
        ),
      ),
    );
  }

  Widget buttonsWidget() {
    return GridView.count(
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      crossAxisCount: 4,
      shrinkWrap: true,
      childAspectRatio: 1.5,
      children: [
        for (var entry in setDateTimes.entries)
          button(getFormattedTimeForTimeSetButton(entry.value), entry.key),
        for (var entry in editDurations.entries)
          button(getFormattedDurationForTimeEditButton(entry.value), entry.key),
      ],
    );
  }

  Widget button(String label, SettingOption option) {
    return ElevatedButton(
      onPressed: () => setSelectedOption(option),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          fontSize: 12
        ),
      ),
      style: selectedSettingOption == option 
      ? Theme.of(context).elevatedButtonTheme.style!.copyWith(
        backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor)
      )
      : Theme.of(context).elevatedButtonTheme.style!.copyWith(
        backgroundColor: WidgetStatePropertyAll(ConstColors.lightGreyLessOpacity)
      ),
    );
  }
}
