import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../provider/settings_provider.dart';
import '../../../../utils/datetime_methods.dart';
import '../../../../widgets/dhm_single_duration_picker.dart';
import '../../../../widgets/save_close_buttons.dart';

class QuickTimeTableModal extends ConsumerStatefulWidget {
  QuickTimeTableModal({super.key});
  @override
  ConsumerState<QuickTimeTableModal> createState() =>
      _QuickTimeTableModalState();
}

class _QuickTimeTableModalState extends ConsumerState<QuickTimeTableModal> {
  int selectedSettingOption = 0; // 0-3 for set options, 4-11 for edit options
  final isNegativeDurationScrollController = FixedExtentScrollController();

  // Helper maps to store temporary values
  late Map<int, DateTime> setDateTimes;
  late Map<int, Duration> editDurations;

  @override
  void initState() {
    super.initState();
    initializeValues();
  }

  void initializeValues() {
    final settings = ref.read(userSettingsProvider);
    setDateTimes = {
      0: settings.quickTimeSetOption1,
      1: settings.quickTimeSetOption2,
      2: settings.quickTimeSetOption3,
      3: settings.quickTimeSetOption4,
    };
    editDurations = {
      4: settings.quickTimeEditOption1,
      5: settings.quickTimeEditOption2,
      6: settings.quickTimeEditOption3,
      7: settings.quickTimeEditOption4,
      8: settings.quickTimeEditOption5,
      9: settings.quickTimeEditOption6,
      10: settings.quickTimeEditOption7,
      11: settings.quickTimeEditOption8,
    };
  }

  void setSelectedOption(int option) {
    setState(() {
      selectedSettingOption = option;
      if (option >= 4) {
        updatePickerPositionsOnButtonChange(editDurations[option]!);
      }
    });
  }

  void updatePickerPositionsOnButtonChange(Duration duration) {
    if (duration.isNegative) {
      isNegativeDurationScrollController.jumpToItem(1);
    } else {
      isNegativeDurationScrollController.jumpToItem(0);
    }
  }

  void onSave() {
    final notifier = ref.read(userSettingsProvider.notifier);
    // Update set options
    notifier.quickTimeSetOption1 = setDateTimes[0]!;
    notifier.quickTimeSetOption2 = setDateTimes[1]!;
    notifier.quickTimeSetOption3 = setDateTimes[2]!;
    notifier.quickTimeSetOption4 = setDateTimes[3]!;
    // Update edit options
    notifier.quickTimeEditOption1 = editDurations[4]!;
    notifier.quickTimeEditOption2 = editDurations[5]!;
    notifier.quickTimeEditOption3 = editDurations[6]!;
    notifier.quickTimeEditOption4 = editDurations[7]!;
    notifier.quickTimeEditOption5 = editDurations[8]!;
    notifier.quickTimeEditOption6 = editDurations[9]!;
    notifier.quickTimeEditOption7 = editDurations[10]!;
    notifier.quickTimeEditOption8 = editDurations[11]!;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Quick Time Table",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Divider(),
          const SizedBox(height: 8),
          _buildButtonsTable(),
          getEditWidget(),
          SaveCloseButtons(onTapSave: onSave),
        ],
      ),
    );
  }

  Widget getEditWidget() {
    if (selectedSettingOption <= 3) {
      return dateTimePickerWidget();
    } else {
      return DHMSingleDurationPicker(
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
    }
  }

  Widget dateTimePickerWidget() {
    return Container(
      width: 400,
      height: 200,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CupertinoTheme(
        data: CupertinoThemeData(brightness: Brightness.dark),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          itemExtent: 70,
          initialDateTime: setDateTimes[selectedSettingOption],
          onDateTimeChanged: (dt) {
            setState(() {
              setDateTimes[selectedSettingOption] = dt;
            });
          },
        ),
      ),
    );
  }

  Widget _buildButtonsTable() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: GridView.count(
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        crossAxisCount: 4,
        shrinkWrap: true,
        childAspectRatio: 1.5,
        children: [
          ...setDateTimes.entries.map(
            (entry) => _buildButton(
                getFormattedTimeForTimeSetButton(entry.value), entry.key),
          ),
          ...editDurations.entries.map(
            (entry) => _buildButton(
                getFormattedDurationForTimeEditButton(entry.value), entry.key),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, int option) {
    return ElevatedButton(
      onPressed: () => setSelectedOption(option),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: option == selectedSettingOption
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.secondaryContainer,
          shape: BeveledRectangleBorder()),
    );
  }
}
