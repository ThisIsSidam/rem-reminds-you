import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../consts/const_colors.dart';
import '../../../../provider/settings_provider.dart';
import '../../../../utils/datetime_methods.dart';
import '../../../../widgets/duration_picker.dart';
import '../../../../widgets/save_close_buttons.dart';

class SnoozeOptionsModal extends ConsumerStatefulWidget {
  SnoozeOptionsModal({super.key});

  @override
  ConsumerState<SnoozeOptionsModal> createState() => _SnoozeOptionsModalState();
}

class _SnoozeOptionsModalState extends ConsumerState<SnoozeOptionsModal> {
  int selectedSettingOption = 0; // 0-5 for autoSnoozeOption1 to 6
  late Map<int, Duration> durations;

  @override
  void initState() {
    super.initState();
    initializeDurations();
  }

  void initializeDurations() {
    final settings = ref.read(userSettingsProvider);
    durations = {
      0: settings.autoSnoozeOption1,
      1: settings.autoSnoozeOption2,
      2: settings.autoSnoozeOption3,
      3: settings.autoSnoozeOption4,
      4: settings.autoSnoozeOption5,
      5: settings.autoSnoozeOption6,
    };
  }

  void setSelectedOption(int option) {
    setState(() {
      selectedSettingOption = option;
    });
  }

  void onSave() {
    final notifier = ref.read(userSettingsProvider);
    // Using direct setter assignment
    notifier.autoSnoozeOption1 = durations[0]!;
    notifier.autoSnoozeOption2 = durations[1]!;
    notifier.autoSnoozeOption3 = durations[2]!;
    notifier.autoSnoozeOption4 = durations[3]!;
    notifier.autoSnoozeOption5 = durations[4]!;
    notifier.autoSnoozeOption6 = durations[5]!;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 600,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            Text("Snooze Options",
                style: Theme.of(context).textTheme.titleLarge),
            Divider(),
            SizedBox(height: 10),
            _buildButtonsGrid(),
            DurationPickerBase(onDurationChange: (dur) {
              setState(() {
                durations[selectedSettingOption] = dur;
              });
            }),
            SaveCloseButtons(onTapSave: onSave)
          ],
        ));
  }

  Widget _buildButtonsGrid() {
    return GridView.count(
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      crossAxisCount: 3,
      shrinkWrap: true,
      childAspectRatio: 1.5,
      children: [
        for (var entry in durations.entries)
          _buildButton(
              getFormattedDurationForTimeEditButton(entry.value,
                  addPlusSymbol: false),
              entry.key),
      ],
    );
  }

  Widget _buildButton(String label, int option) {
    return ElevatedButton(
      onPressed: () => setSelectedOption(option),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14),
      ),
      style: selectedSettingOption == option
          ? Theme.of(context).elevatedButtonTheme.style!.copyWith(
              backgroundColor:
                  WidgetStatePropertyAll(Theme.of(context).primaryColor))
          : Theme.of(context).elevatedButtonTheme.style!.copyWith(
              backgroundColor:
                  WidgetStatePropertyAll(ConstColors.lightGreyLessOpacity)),
    );
  }
}
