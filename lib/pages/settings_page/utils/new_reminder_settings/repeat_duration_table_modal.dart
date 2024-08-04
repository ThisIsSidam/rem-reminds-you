import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/utils/functions/datetime_methods.dart';
import 'package:Rem/utils/flex_picker/flex_duration_picker.dart';
import 'package:Rem/utils/other_utils/save_close_buttons.dart';
import 'package:flutter/material.dart';

class RepeatDurationTableModal extends StatefulWidget {

  RepeatDurationTableModal({
    super.key
  });

  @override
  State<RepeatDurationTableModal> createState() => _RepeatDurationTableModalState();
}

class _RepeatDurationTableModalState extends State<RepeatDurationTableModal> {
  Duration currentValueFromDurationPicker = UserDB.getSetting(SettingOption.RepeatIntervalOption1);
  SettingOption selectedSettingOption = SettingOption.RepeatIntervalOption1;

  final durationController = FlexDurationPickerController();

  final Map<SettingOption, Duration>  durations = {
    for (int i = 15; i <= 20; i++) // Starting and Ending indexes of repeatDurations in enum
      SettingsOptionMethods.fromInt(i): UserDB.getSetting(SettingsOptionMethods.fromInt(i))
  };

  @override
  void initState() {
    durationController.updateDuration(currentValueFromDurationPicker);
    refresh();
    super.initState();
  }

  void refresh() {
    setState(() {
    });
  }

  void setSelectedOption(SettingOption option) {
    setState(() {
      selectedSettingOption = option;
      currentValueFromDurationPicker = durations[selectedSettingOption]!;
      durationController.updateDuration(currentValueFromDurationPicker);
    });
  }

  void onSave() {
    durations.forEach((option, dur) {
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
          durationPickerWidget(),
          SaveCloseButtons(
            onTapSave: onSave
          )
        ],
      )
    );
  }

  Widget durationPickerWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FlexDurationPicker(
        controller: durationController,
        mode: FlexDurationPickerMode.hm,
        onDurationChanged: (dur) {
          durations[selectedSettingOption] = dur;
          refresh();
        }
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
        crossAxisCount: 3,
        shrinkWrap: true,
        childAspectRatio: 1.5,
        children: [
          for (var entry in durations.entries)
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
