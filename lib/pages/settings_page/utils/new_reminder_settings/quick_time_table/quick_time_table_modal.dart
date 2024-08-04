import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/pages/settings_page/utils/new_reminder_settings/quick_time_table/duration_picker.dart';
import 'package:Rem/utils/functions/datetime_methods.dart';
import 'package:Rem/utils/flex_picker/flex_duration_picker.dart';
import 'package:Rem/utils/flex_picker/flex_time_picker.dart';
import 'package:Rem/utils/other_utils/save_close_buttons.dart';
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

  late FlexDurationPickerController durationController;
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
    durationController = FlexDurationPickerController(initialDuration: currentValueFromDurationPicker);
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
    final bool neg = currentValueFromDurationPicker.isNegative;
    durationController.updateDuration(
      neg ? -currentValueFromDurationPicker : currentValueFromDurationPicker
    );

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
        return QuickTimeTableDurationPicker(
          duration: editDurations[selectedSettingOption]!,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FlexDateTimePicker(
        initalTime: currentValueFromTimePicker,
        mode: FlexDateTimePickerMode.hm,
        onDateTimeChanged: (dt) {
          setDateTimes[selectedSettingOption] = dt;
          refresh();
        },
      ),
    );
  }

  Widget buttonsWidget() {
    return Container(
      
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.white
        )
      ),
      child: GridView.count(
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        crossAxisCount: 4,
        shrinkWrap: true,
        childAspectRatio: 1.5,
        children: [
          for (var entry in setDateTimes.entries)
            button(getFormattedTimeForTimeSetButton(entry.value), entry.key),
          for (var entry in editDurations.entries)
            button(getFormattedDurationForTimeEditButton(entry.value), entry.key),
        ],
      )
    );
  }

  Widget button(String label, SettingOption option) {
    return ElevatedButton(
      onPressed: () => setSelectedOption(option),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      style: selectedSettingOption == option 
      ? Theme.of(context).elevatedButtonTheme.style!.copyWith(
        backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor)
      )
      : Theme.of(context).elevatedButtonTheme.style,
    );
  }
}
