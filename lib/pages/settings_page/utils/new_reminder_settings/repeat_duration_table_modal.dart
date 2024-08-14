import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/utils/other_utils/duration_picker.dart';
import 'package:Rem/utils/functions/datetime_methods.dart';
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


  final Map<SettingOption, Duration>  durations = {
    for (int i = 15; i <= 20; i++) // Starting and Ending indexes of repeatDurations in enum
      SettingsOptionMethods.fromInt(i): UserDB.getSetting(SettingsOptionMethods.fromInt(i))
  };

  @override
  void initState() {
    super.initState();
  }
  void setSelectedOption(SettingOption option) {
    setState(() {
      selectedSettingOption = option;
      currentValueFromDurationPicker = durations[selectedSettingOption]!;
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
          Text("Repeat Duration Table", style: Theme.of(context).textTheme.titleLarge),
          Divider(),
          SizedBox(height: 10),
          buttonsWidget(),
          DurationPickerBase(
            onDurationChange: (dur) {
              setState(() {
                durations[selectedSettingOption] = dur;
              });
            }
          ),
          SaveCloseButtons(
            onTapSave: onSave
          )
        ],
      )
    );
  }

  Widget buttonsWidget() {
    return GridView.count(
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      crossAxisCount: 3,
      shrinkWrap: true,
      childAspectRatio: 1.5,
      children: [
        for (var entry in durations.entries)
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
          fontSize: 14
        ),
      ),
      style: selectedSettingOption == option 
      ? Theme.of(context).elevatedButtonTheme.style!.copyWith(
        backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor)
      )
      : Theme.of(context).elevatedButtonTheme.style,
    );
  }
}
